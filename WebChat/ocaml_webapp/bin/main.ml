open Opium
open Ocaml_webapp

(** [register_user] creates a post request that takes in a json
    containing the email, password, username of a new user and outputs
    "Email taken" if users contains the email already, "Username taken"
    if users contains the username already, and "Success" if the
    information can be used to create a user that is added to usrlst *)
let register_user =
  App.post "/register" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun user_json ->
          let user_info = user_json |> User.user_of_yojson in
          Lwt.bind (User.email_exists user_info.email ()) (fun resp ->
              match resp with
              | Ok true ->
                  Lwt.return (Response.of_plain_text "Email taken")
              | Ok false ->
                  Lwt.bind (User.username_exists user_info.username ())
                    (fun resp2 ->
                      match resp2 with
                      | Ok true ->
                          Lwt.return
                            (Response.of_plain_text "Username taken")
                      | Ok false ->
                          Lwt.bind
                            (User.add_usr user_info.email
                               user_info.password user_info.username ())
                            (fun _ ->
                              Lwt.return
                                (Response.of_plain_text "Success"))
                      | Error e -> Lwt.fail (failwith e))
              | Error e -> Lwt.fail (failwith e))))

(** [login_user] creates a post request that takes in the json
    containing the information for a user x and outputs "No User" if x
    is not in users and a json containing the email and username of x
    otherwise *)
let login_user =
  App.post "/login" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun user_json ->
          let user_info = user_json |> User.user_of_yojson in
          Lwt.bind
            (User.check_password user_info.email user_info.password
               user_info.username ()) (fun resp ->
              match resp with
              | Ok true ->
                  Lwt.bind (User.email_exists user_info.email ())
                    (fun resp2 ->
                      match resp2 with
                      | Ok true ->
                          Lwt.bind
                            (User.user_of_email user_info.email ())
                            (fun resp3 ->
                              match resp3 with
                              | Ok usernam ->
                                  Lwt.return
                                    (Response.of_json
                                       (`Assoc
                                         [
                                           ( "email",
                                             `String user_info.email );
                                           ("username", `String usernam);
                                         ]))
                              | Error e -> Lwt.fail (failwith e))
                      | Ok false ->
                          Lwt.bind
                            (User.email_of_user user_info.username ())
                            (fun resp4 ->
                              match resp4 with
                              | Ok emai ->
                                  Lwt.return
                                    (Response.of_json
                                       (`Assoc
                                         [
                                           ("email", `String emai);
                                           ( "username",
                                             `String user_info.username
                                           );
                                         ]))
                              | Error e -> Lwt.fail (failwith e))
                      | Error e -> Lwt.fail (failwith e))
              | Ok false ->
                  Lwt.return (Response.of_plain_text "No User")
              | Error e -> Lwt.fail (failwith e))))

let change_username =
  App.post "/changeUsername" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun resp ->
          match resp with
          | `Assoc
              [
                ("email", `String email); ("username", `String username);
              ] ->
              Lwt.bind (User.change_username email username ())
                (fun resp2 ->
                  match resp2 with
                  | Ok () -> Lwt.return (Response.make ~status:`OK ())
                  | Error e -> Lwt.fail (failwith e))
          | _ -> Lwt.return (Response.of_plain_text "invalid username")))

let rec wrap_userlist (u : string list) =
  match u with
  | [] -> []
  | h :: t -> `String h :: wrap_userlist t

let rec convo_helper lst =
  let open Conversations in
  let open UserConversation in
  match lst with
  | [] -> Lwt.return []
  | h :: t ->
      Lwt.bind (get_users_from_conversationid h.conversation_id ())
        (fun l1_response ->
          match l1_response with
          | Ok uidlist ->
              Lwt.bind (read_conversation_given_id h.conversation_id ())
                (fun response ->
                  match response with
                  | Ok one_convo -> (
                      match one_convo with
                      | [] -> failwith "DNE"
                      | [ h2 ] ->
                          Lwt.bind (convo_helper t) (fun tail ->
                              Lwt.return
                                (`Assoc
                                   [
                                     ( "conversation_name",
                                       `String h2.conversation_name );
                                     ( "conversation_id",
                                       `Int h.conversation_id );
                                     ( "creator_email",
                                       `String h2.creator_id );
                                     ( "users",
                                       `List (uidlist |> wrap_userlist)
                                     );
                                   ]
                                :: tail))
                      | _ -> failwith "only one element")
                  | Error e -> Lwt.fail (failwith e))
          | Error e -> Lwt.fail (failwith e))

let rec gen_user_convos convoid userlist creatorid =
  match userlist with
  | [] -> Lwt.return (Response.of_plain_text "Success")
  | h :: t ->
      Lwt.bind (User.id_from_email h ()) (fun uid ->
          match uid with
          | Ok cur_user ->
              Lwt.bind
                (Contacts.does_contact_exist creatorid cur_user ())
                (fun exists ->
                  match exists with
                  | Ok true ->
                      Lwt.bind
                        (UserConversation.insert_user_conversation
                           convoid cur_user ()) (fun response ->
                          match response with
                          | Ok () -> gen_user_convos convoid t creatorid
                          | Error e -> Lwt.fail (failwith e))
                  | Ok false ->
                      Lwt.return (Response.of_plain_text "Failure")
                  | Error e -> Lwt.fail (failwith e))
          | Error e -> Lwt.fail (failwith e))

(** [make_conversation] creates a post request that takes in a json
    containing the conversation name, creator name, and list of contacts
    of a new conversation and outputs "invalid" if json does not parse
    correctly, "failure"/Lwt.fail if contacts from list are not real or
    actual contacts of user, and "Success" if the information can be
    used to create a conversation that is added to convolst*)
let make_conversation =
  App.post "/makeConversation" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun input_json ->
          let convo_creator_pair x =
            match x with
            | `Assoc
                [
                  ("conversation_name", `String convo);
                  ("creator_name", `String creator);
                  _;
                ] ->
                (convo, creator)
            | _ -> failwith "invalid convo"
          in
          let user_list (y : Yojson.Safe.t) =
            match y with
            | `Assoc [ _; _; ("contacts", `List contacts) ] -> contacts
            | _ -> failwith "invalid convo"
          in
          let rec parse_user_list (lst : Yojson.Safe.t list) =
            match lst with
            | [] -> []
            | `String (user : string) :: t -> user :: parse_user_list t
            | _ -> failwith "invalid"
          in
          Lwt.bind
            (User.id_from_email
               (snd (convo_creator_pair input_json))
               ())
            (fun response ->
              match response with
              | Ok creatorid ->
                  Lwt.bind
                    (Conversations.insert_convo
                       (fst (convo_creator_pair input_json))
                       (snd (convo_creator_pair input_json))
                       ())
                    (fun create_response ->
                      match create_response with
                      | Ok id ->
                          Lwt.bind
                            (UserConversation.insert_user_conversation
                               id creatorid ()) (fun response ->
                              match response with
                              | Ok () ->
                                  gen_user_convos id
                                    (input_json |> user_list
                                   |> parse_user_list)
                                    creatorid
                              | Error e -> Lwt.fail (failwith e))
                      | Error e -> Lwt.fail (failwith e))
              | Error e -> Lwt.fail (failwith e))))

(** [get_conversations] creates a post request that takes in a json
    containing the email of the user and outputs "failure"/Lwt.fail if
    email is invalid or "Success" if the information can be used to
    retireve the conversations that are tied to the user email given.
    This is given from retriving data from usrlst, convolst, and
    userconvolst*)
let get_conversations =
  let open UserConversation in
  let open User in
  App.post "/getConversations" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun contact_json ->
          let users_info = contact_json |> usercontact_of_yojson in
          Lwt.bind (id_from_email users_info.email ()) (fun response ->
              match response with
              | Ok userid ->
                  Lwt.bind (read_conversations_given_user userid ())
                    (fun convoids ->
                      match convoids with
                      | Ok convolst ->
                          Lwt.bind (convo_helper convolst)
                            (fun return ->
                              match return with
                              | json_return ->
                                  Lwt.return
                                    (Response.of_json
                                       (`Assoc
                                         [ ("data", `List json_return) ])))
                      | Error e -> Lwt.fail (failwith e))
              | Error e2 -> Lwt.fail (failwith e2))))

let rec contacts_helper lst =
  let open Contacts in
  let open User in
  match lst with
  | [] -> Lwt.return []
  | h :: t ->
      Lwt.bind (read_all_given_id h.contact_id ()) (fun response ->
          match response with
          | Ok one_contact -> (
              match one_contact with
              | [] -> failwith "DNE"
              | [ h2 ] ->
                  Lwt.bind (contacts_helper t) (fun resp ->
                      match resp with
                      | tail ->
                          Lwt.return
                            (`Assoc
                               [
                                 ("email", `String h2.email);
                                 ("username", `String h2.username);
                                 ("favorite", `Bool h.favorite);
                               ]
                            :: tail))
              | _ -> failwith "only one element")
          | Error e -> Lwt.fail (failwith e))

(** [get_contacts] creates a post request that takes in a json
    containing the email of the user and outputs "failure"/Lwt.fail if
    email is invalid or "Success" if the information can be used to
    retireve the contacts that are tied to the user email given. This is
    given from retriving data from usrlst and contactslst*)
let get_contacts =
  let open User in
  let open Contacts in
  App.post "/getContacts" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun contact_json ->
          let users_info = contact_json |> usercontact_of_yojson in
          Lwt.bind (id_from_email users_info.email ()) (fun response ->
              match response with
              | Ok userid ->
                  Lwt.bind (read_contacts_given_userid userid ())
                    (fun response ->
                      match response with
                      | Ok contacts ->
                          Lwt.bind (contacts_helper contacts)
                            (fun return ->
                              match return with
                              | json_return ->
                                  Lwt.return
                                    (Response.of_json
                                       (`Assoc
                                         [ ("data", `List json_return) ])))
                      | Error e -> Lwt.fail (failwith e))
              | Error e2 -> Lwt.fail (failwith e2))))

(** [make_favorite] creates a post request that takes in a json
    containing the email of the user and contact and outputs
    "failure"/Lwt.fail if emails are invalid or "Success" if the
    information can be used to update the favorite value of the user and
    contact that are tied to contactslst. *)
let make_favorite =
  let open User in
  let open Contacts in
  App.post "/makeFavorite" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun contact_json ->
          let both_info = contact_json |> both_of_yojson in
          Lwt.bind (id_from_email both_info.user_email ())
            (fun user_response ->
              match user_response with
              | Ok userid ->
                  Lwt.bind (id_from_email both_info.contact_email ())
                    (fun contact_response ->
                      match contact_response with
                      | Ok contactid ->
                          Lwt.bind
                            (does_contact_exist userid contactid ())
                            (fun response ->
                              match response with
                              | Ok true ->
                                  Lwt.bind
                                    (update_make_favorite userid
                                       contactid ()) (fun update ->
                                      match update with
                                      | Ok _ ->
                                          Lwt.return
                                            (Response.of_plain_text
                                               "Success")
                                      | Error e -> Lwt.fail (failwith e))
                              | Ok false ->
                                  failwith "contact does not exist"
                              | Error e -> Lwt.fail (failwith e))
                      | Error e1 -> Lwt.fail (failwith e1))
              | Error e2 -> Lwt.fail (failwith e2))))

(** [remove_favorite] creates a post request that takes in a json
    containing the email of the user and contact and outputs
    "failure"/Lwt.fail if emails are invalid or "Success" if the
    information can be used to update the favorite value of the user and
    contact that are tied to contactslst. *)
let remove_favorite =
  let open User in
  let open Contacts in
  App.post "/removeFavorite" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun contact_json ->
          let both_info = contact_json |> both_of_yojson in
          Lwt.bind (id_from_email both_info.user_email ())
            (fun user_response ->
              match user_response with
              | Ok userid ->
                  Lwt.bind (id_from_email both_info.contact_email ())
                    (fun contact_response ->
                      match contact_response with
                      | Ok contactid ->
                          Lwt.bind
                            (does_contact_exist userid contactid ())
                            (fun response ->
                              match response with
                              | Ok true ->
                                  Lwt.bind
                                    (update_remove_favorite userid
                                       contactid ()) (fun update ->
                                      match update with
                                      | Ok _ ->
                                          Lwt.return
                                            (Response.of_plain_text
                                               "Success")
                                      | Error e -> Lwt.fail (failwith e))
                              | Ok false ->
                                  failwith "contact does notexist"
                              | Error e -> Lwt.fail (failwith e))
                      | Error e1 -> Lwt.fail (failwith e1))
              | Error e2 -> Lwt.fail (failwith e2))))

(** [add_conversation] creates a post request that takes in a json
    containing the user and contact emails and outputs
    "failure"/Lwt.fail if emails are not in userlst, and "Success" if
    the information can be used to add a contact from given user to
    contact that is added to contactlst*)
let add_contact =
  let open Contacts in
  let open User in
  App.post "/addContact" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun contact_json ->
          let both_info = contact_json |> both_of_yojson in
          Lwt.bind (id_from_email both_info.user_email ())
            (fun accepted ->
              match accepted with
              | Ok user_id ->
                  Lwt.bind (id_from_email both_info.contact_email ())
                    (fun contact_response ->
                      match contact_response with
                      | Ok contactid ->
                          Lwt.bind
                            (does_contact_exist user_id contactid ())
                            (fun existing_responses ->
                              match existing_responses with
                              | Ok true ->
                                  Lwt.return
                                    (Response.of_plain_text
                                       "Contact already exists")
                              | Ok false ->
                                  Lwt.bind
                                    (insert_contact user_id contactid
                                       false ()) (fun add ->
                                      match add with
                                      | Ok _ ->
                                          Lwt.return
                                            (Response.of_plain_text
                                               "Success")
                                      | Error e -> Lwt.fail (failwith e))
                              | Error e3 -> Lwt.fail (failwith e3))
                      | Error e4 -> Lwt.fail (failwith e4))
              | Error e2 -> Lwt.fail (failwith e2))))

let rec interpret_msglist mlst =
  let open User in
  let open Storage in
  match mlst with
  | [] -> Lwt.return []
  | h :: t ->
      Lwt.bind (read_all_given_id h.senderid ()) (fun response ->
          match response with
          | Ok one_user -> (
              match one_user with
              | [] -> failwith "DNE"
              | [ h2 ] ->
                  Lwt.bind (interpret_msglist t)
                    (fun msg_list_response ->
                      match msg_list_response with
                      | tail ->
                          Lwt.return
                            (`Assoc
                               [
                                 ("username", `String h2.username);
                                 ("message", `String h.msg);
                               ]
                            :: tail))
              | _ -> failwith "only one element")
          | Error e -> Lwt.fail (failwith e))

(** [get_messages] creates a post request that takes in a json
    containing the id of the conversation and outputs "failure"/Lwt.fail
    if email is invalid or "Success" if the information can be used to
    retireve the messages that are tied to the conversation id given.
    This is given from retriving data from userconvolst and convolst*)
let get_messages =
  let open UserConversation in
  let open Storage in
  App.post "/getMessages" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun convo_json ->
          let convo_id = convo_json |> convo_of_yojson in
          Lwt.bind (read_conversation_msgs convo_id.id ())
            (fun msg_response ->
              match msg_response with
              | Ok msg_list ->
                  Lwt.bind (interpret_msglist msg_list)
                    (fun complete_response ->
                      match complete_response with
                      | return_msg_list ->
                          Lwt.return
                            (Response.of_json
                               (`Assoc
                                 [ ("data", `List return_msg_list) ])))
              | Error e -> Lwt.fail (failwith e))))

(* [post_message] creates a post request that takes in a json containing
   the sender email, conversation id, and message of a message and adds
   a message with the user id, conversation id, and message as fields to
   msglst. Outputs "failure"/Lwt.fail if email is invalid or if
   conversation_id is not unique or existing, or "Success" if the
   information can be used to create the message. *)
let post_message =
  App.post "/postMessage" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun convo_json ->
          match convo_json with
          | `Assoc
              [
                ("sender_email", `String senderemail);
                ("conversation_id", `Int convoid);
                ("message", `String msg);
                ("bob", `Bool bob);
                ("joe", `Bool joe);
              ] ->
              Lwt.bind (User.id_from_email senderemail ())
                (fun id_response ->
                  match id_response with
                  | Ok user_id ->
                      Lwt.bind (Storage.add_msg user_id convoid msg ())
                        (fun resp ->
                          match resp with
                          | Ok () ->
                              if bob then
                                Lwt.bind
                                  (Storage.add_msg 1 convoid
                                     (snd (Bot.bob_bot_response msg 4))
                                     ())
                                  (fun bob_response ->
                                    match bob_response with
                                    | Ok () ->
                                        if joe then
                                          if
                                            fst
                                              (Bot.joe_bot_response msg
                                                 0)
                                            = true
                                          then
                                            Lwt.bind
                                              (Storage.add_msg 2 convoid
                                                 (snd
                                                    (Bot
                                                     .joe_bot_response
                                                       msg 0))
                                                 ())
                                              (fun joe_response ->
                                                match joe_response with
                                                | Ok () ->
                                                    Lwt.return
                                                      (Response.make
                                                         ~status:`OK ())
                                                | Error e ->
                                                    Lwt.fail
                                                      (failwith e))
                                          else
                                            Lwt.return
                                              (Response.make ~status:`OK
                                                 ())
                                        else
                                          Lwt.return
                                            (Response.make ~status:`OK
                                               ())
                                    | Error e -> Lwt.fail (failwith e))
                              else if joe then
                                if
                                  fst (Bot.joe_bot_response msg 0)
                                  = true
                                then
                                  Lwt.bind
                                    (Storage.add_msg 2 convoid
                                       (snd
                                          (Bot.joe_bot_response msg 0))
                                       ())
                                    (fun joe_response ->
                                      match joe_response with
                                      | Ok () ->
                                          Lwt.return
                                            (Response.make ~status:`OK
                                               ())
                                      | Error e -> Lwt.fail (failwith e))
                                else
                                  Lwt.return
                                    (Response.make ~status:`OK ())
                              else
                                Lwt.return
                                  (Response.make ~status:`OK ())
                          | Error e -> Lwt.fail (failwith e))
                  | Error e -> Lwt.fail (failwith e))
          | _ -> failwith "oops"))

let bind_functions fun1 fun2 =
  Lwt.bind fun1 (fun resp ->
      match resp with
      | Ok () -> fun2
      | Error e -> Lwt.fail (failwith e))

(** [creates_db] initiates the databse with bob the bot and starts up
    tables in lib modules*)
let create_db =
  App.get "/create" (fun _ ->
      Lwt.bind (User.migrate ()) (fun resp ->
          match resp with
          | Ok () ->
              Lwt.bind (User.username_exists "Bob-bot" ()) (fun resp2 ->
                  match resp2 with
                  | Ok false ->
                      Lwt.bind
                        (User.add_usr "bob" "Bob Bot" "Bob-bot" ())
                        (fun resp3 ->
                          match resp3 with
                          | Ok () ->
                              Lwt.bind
                                (User.username_exists "Joe-bot" ())
                                (fun resp4 ->
                                  match resp4 with
                                  | Ok false ->
                                      Lwt.bind
                                        (User.add_usr "joe" "Joe Bot"
                                           "Joe-bot" ()) (fun f ->
                                          match f with
                                          | Ok () ->
                                              bind_functions
                                                (Storage.migrate ())
                                                (bind_functions
                                                   (Contacts.migrate ())
                                                   (bind_functions
                                                      (Conversations
                                                       .migrate ())
                                                      (bind_functions
                                                         (UserConversation
                                                          .migrate ())
                                                         (Lwt.return
                                                            (Response
                                                             .make
                                                               ~status:
                                                                 `OK ())))))
                                          | Error e ->
                                              Lwt.fail (failwith e))
                                  | Ok true ->
                                      bind_functions
                                        (Storage.migrate ())
                                        (bind_functions
                                           (Contacts.migrate ())
                                           (bind_functions
                                              (Conversations.migrate ())
                                              (bind_functions
                                                 (UserConversation
                                                  .migrate ())
                                                 (Lwt.return
                                                    (Response.make
                                                       ~status:`OK ())))))
                                  | Error e -> Lwt.fail (failwith e))
                          | Error e -> Lwt.fail (failwith e))
                  | Ok true ->
                      Lwt.bind (User.username_exists "Joe-bot" ())
                        (fun resp5 ->
                          match resp5 with
                          | Ok false ->
                              Lwt.bind
                                (User.add_usr "joe" "Joe Bot" "Joe-bot"
                                   ()) (fun resp6 ->
                                  match resp6 with
                                  | Ok () ->
                                      bind_functions
                                        (Storage.migrate ())
                                        (bind_functions
                                           (Contacts.migrate ())
                                           (bind_functions
                                              (Conversations.migrate ())
                                              (bind_functions
                                                 (UserConversation
                                                  .migrate ())
                                                 (Lwt.return
                                                    (Response.make
                                                       ~status:`OK ())))))
                                  | Error e -> Lwt.fail (failwith e))
                          | Ok true ->
                              bind_functions (Storage.migrate ())
                                (bind_functions (Contacts.migrate ())
                                   (bind_functions
                                      (Conversations.migrate ())
                                      (bind_functions
                                         (UserConversation.migrate ())
                                         (Lwt.return
                                            (Response.make ~status:`OK
                                               ())))))
                          | Error e -> Lwt.fail (failwith e))
                  | Error e -> Lwt.fail (failwith e))
          | Error e -> Lwt.fail (failwith e)))

(**[close_db] drops tables of all databases *)
let close_db =
  App.get "/close" (fun _ ->
      bind_functions (User.rollback ())
        (bind_functions (Storage.rollback ())
           (bind_functions (Contacts.rollback ())
              (bind_functions
                 (Conversations.rollback ())
                 (bind_functions
                    (UserConversation.rollback ())
                    (Lwt.return (Response.make ~status:`OK ())))))))

(* cors creates a middleware that fixes cors policy errors that are
   encountered when trying to make requests to the server*)
let cors =
  Middleware.allow_cors
    ~origins:[ "http://localhost:8080" ]
    ~credentials:true ()

(* static_content creates a middleware that serves the frontend static
   files so that the app can be accessed from the browser *)
let static_content =
  Middleware.static_unix ~local_path:(Unix.realpath "frontend/dist") ()

(* Creates the app with the above functions *)
let _ =
  App.empty |> App.middleware cors |> create_db |> close_db
  |> App.middleware static_content
  |> register_user |> login_user |> change_username |> get_messages
  |> post_message |> add_contact |> get_contacts |> get_conversations
  |> make_favorite |> remove_favorite |> make_conversation
  |> App.run_command
