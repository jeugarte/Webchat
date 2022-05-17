open Opium
open Ocaml_webapp

(* register_user creates a post request that takes in a json containing
   the email, password, username of a new user and outputs "Email taken"
   if users contains the email already, "Username taken" if users
   contains the username already, and "Success" if the information can
   be used to create a user that is added to users *)
let register_user =
  App.post "/register" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun user_json ->
          let user_info = user_json |> User.user_of_yojson in
          Lwt.bind (User.email_exists user_info.email ()) (fun x ->
              match x with
              | Ok true ->
                  Lwt.return (Response.of_plain_text "Email taken")
              | Ok false ->
                  Lwt.bind (User.username_exists user_info.username ())
                    (fun y ->
                      match y with
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

(* login_user creates a post request that takes in the json containing
   the information for a user x and outputs "No User" if x is not in
   users and a json containing the email and username of x otherwise *)
let login_user =
  App.post "/login" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun user_json ->
          let user_info = user_json |> User.user_of_yojson in
          Lwt.bind
            (User.check_password user_info.email user_info.password
               user_info.username ()) (fun x ->
              match x with
              | Ok true ->
                  Lwt.bind (User.email_exists user_info.email ())
                    (fun y ->
                      match y with
                      | Ok true ->
                          Lwt.bind
                            (User.user_of_email user_info.email ())
                            (fun z ->
                              match z with
                              | Ok a ->
                                  Lwt.return
                                    (Response.of_json
                                       (`Assoc
                                         [
                                           ( "email",
                                             `String user_info.email );
                                           ("username", `String a);
                                         ]))
                              | Error e -> Lwt.fail (failwith e))
                      | Ok false ->
                          Lwt.bind
                            (User.email_of_user user_info.username ())
                            (fun b ->
                              match b with
                              | Ok c ->
                                  Lwt.return
                                    (Response.of_json
                                       (`Assoc
                                         [
                                           ("email", `String c);
                                           ( "username",
                                             `String user_info.username
                                           );
                                         ]))
                              | Error e -> Lwt.fail (failwith e))
                      | Error e -> Lwt.fail (failwith e))
              | Ok false ->
                  Lwt.return (Response.of_plain_text "No User")
              | Error e -> Lwt.fail (failwith e))))

(* let rec convo_helper lst = let open Conversations in let open
   UserConversation in match lst with | [] -> Lwt.return [] | h :: t ->
   Lwt.bind (read_conversation_given_id h.conversation_id ()) (fun
   response -> match response with | Ok one_convo -> ( match one_convo
   with | [] -> failwith "DNE" | [ h2 ] -> Lwt.bind (convo_helper t)
   (fun s -> match s with | d -> Lwt.return (`Assoc [ (
   "conversation_name", `String h2.conversation_name ); ("creator_name",
   `String h2.creator_id); ] :: d)) | _ -> failwith "only one element")
   | Error e -> Lwt.fail (failwith e)) *)

(** [get_conversations] returns the conversations of a specfic user RI:
    takes in a user id*)
(* let get_conversations (user : int) = let open UserConversation in
   App.get "/getConversations" (fun _ -> Lwt.bind
   (read_conversations_given_user user ()) (fun convoids -> match
   convoids with | Ok convolst -> Lwt.bind (convo_helper convolst) (fun
   return -> match return with | json_return -> Lwt.return
   (Response.of_json (`Assoc [ ("data", `List json_return) ]))) | Error
   e -> Lwt.fail (failwith e))) *)

(* let rec contacts_helper lst = let open Contacts in let open User in
   match lst with | [] -> Lwt.return [] | h :: t -> Lwt.bind
   (read_all_given_id h.contact_id ()) (fun response -> match response
   with | Ok one_contact -> ( match one_contact with | [] -> failwith
   "DNE" | [ h2 ] -> Lwt.bind (contacts_helper t) (fun s -> match s with
   | d -> Lwt.return (`Assoc [ ("email", `String h2.email); ("username",
   `String h2.username); ] :: d)) | _ -> failwith "only one element") |
   Error e -> Lwt.fail (failwith e)) *)

(** [get_contacts] returns an association list of a user's contacts with
    their email and username RI: takes in a user id*)
(* let get_contacts (user : int) = let open Contacts in App.get
   "/getContacts" (fun _ -> Lwt.bind (read_contacts_given_userid user
   ()) (fun response -> match response with | Ok contacts -> Lwt.bind
   (contacts_helper contacts) (fun return -> match return with |
   json_return -> Lwt.return (Response.of_json (`Assoc [ ("data", `List
   json_return) ]))) | Error e -> Lwt.fail (failwith e))) *)

(** [create_conversation] returns success if the conversation with given
    user ids was created; Failure otherwise. RI: takes in a list of user
    ids let create_conversation = let open Conversations in App.post
    "/createConversation" (fun users -> Lwt.bind (Request.to_json_exn
    users) (fun users_json -> let user_info = users_json |>
    User.user_of_yojson in ))*)

(** [make_favorite] returns a success text when the contact is now a
    favorite contact of the user.contact_id Otherwise, it returns
    "contact does not exist" or an Lwt error RI: user and contact are
    ids represented as ids*)

(* let make_favorite user contact = let open Contacts in App.post
   "/makeFavorite" (fun _ -> Lwt.bind (does_contact_exist user contact
   ()) (fun response -> match response with | Ok true -> Lwt.bind
   (update_make_favorite user contact ()) (fun update -> match update
   with | Ok _ -> Lwt.return (Response.of_plain_text "Success") | Error
   e -> Lwt.fail (failwith e)) | Ok false -> failwith "contact does not
   exist" | Error e -> Lwt.fail (failwith e))) *)

(* let add_contact user = let open Contacts in let open User in App.post
   "/addContact" (fun request -> Lwt.bind (Request.to_json_exn request)
   (fun contact_json -> let contact_info = contact_json |>
   User.user_of_yojson in Lwt.bind (id_from_email contact_info.email ())
   (fun accepted -> match accepted with | Ok contact_id -> Lwt.bind
   (does_contact_exist user contact_id ()) (fun existing_responses ->
   match existing_responses with | Ok true -> Lwt.return
   (Response.of_plain_text "Contact already exists") | Ok false ->
   Lwt.bind (insert_contact user contact_id false ()) (fun add -> match
   add with | Ok _ -> Lwt.return (Response.of_plain_text "Success") |
   Error e -> Lwt.fail (failwith e)) | Error e3 -> Lwt.fail (failwith
   e3)) | Error e2 -> Lwt.fail (failwith e2)))) *)

(* get_users creates a get request that outputs users for testing
   purposes *)
(* let get_users = App.get "/users" (fun _ -> let users = !users in let
   rec json x = match x with | [] -> [] | h :: t -> User.yojson_of_user
   (h) :: json t in Lwt.return (Response.of_json (`Assoc [ ("users",
   `List (json users))]))) *)

(* read_messages creates a get request that outputs a json containing
   the list of messages as objects with username and the message Raises:
   "no users" if the userid associated with a message is not an email in
   users (this should not occur as userid should be immutable after
   registration) *)
let read_messages =
  App.get "/getMessages" (fun _ ->
      Lwt.bind (Storage.read_all ()) (fun x ->
          match x with
          | Ok a ->
              let messages = a in
              let rec json (x : Storage.message list) =
                match x with
                | [] -> Lwt.return []
                | h1 :: t1 ->
                    Lwt.bind (User.email_exists h1.senderid ())
                      (fun y ->
                        match y with
                        | Ok true ->
                            Lwt.bind (User.user_of_email h1.senderid ())
                              (fun z ->
                                match z with
                                | Ok b ->
                                    Lwt.bind (json t1) (fun s ->
                                        match s with
                                        | d ->
                                            Lwt.return
                                              (`Assoc
                                                 [
                                                   ( "username",
                                                     `String b );
                                                   ( "message",
                                                     `String h1.msg );
                                                 ]
                                              :: d))
                                | Error e -> Lwt.fail (failwith e))
                        | Ok false -> Lwt.fail (failwith "no users")
                        | Error e -> Lwt.fail (failwith e))
              in
              Lwt.bind (json messages) (fun a ->
                  match a with
                  | c ->
                      Lwt.return
                        (Response.of_json
                           (`Assoc [ ("data", `List c) ])))
          | Error e -> Lwt.fail (failwith e)))

(* post_messages creates a post request that takes in a json containing
   the username and message of a message and adds a message with the
   userid/email and message as fields to messages Raises: "no users" if
   the username in the json does not match the current username of any
   user in users "invalid message json" if the input json does not
   contain username and message *)
let post_messages =
  App.post "/postMessage" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun input_json ->
          let match_user x =
            match x with
            | `Assoc [ ("username", `String username); _ ] -> username
            | _ -> failwith "invalid message json"
          in
          Lwt.bind
            (User.username_exists (match_user input_json) ())
            (fun q ->
              match q with
              | Ok true ->
                  Lwt.bind
                    (User.email_of_user (match_user input_json) ())
                    (fun r ->
                      match r with
                      | Ok a ->
                          Lwt.bind
                            (Storage.add_msg a "all"
                               (let match_message y =
                                  match y with
                                  | `Assoc
                                      [
                                        _; ("message", `String message);
                                      ] ->
                                      message
                                  | _ -> failwith "invalid message json"
                                in
                                match_message input_json)
                               ())
                            (fun s ->
                              match s with
                              | Ok () ->
                                  Lwt.return
                                    (Response.make ~status:`OK ())
                              | Error e -> Lwt.fail (failwith e))
                      | Error e -> Lwt.fail (failwith e))
              | Ok false -> failwith "no users"
              | Error e -> Lwt.fail (failwith e))))

let post_messages_bot =
  App.post "/postMessageBot" (fun request ->
      Lwt.bind (Request.to_json_exn request) (fun input_json ->
          let match_user x =
            match x with
            | `Assoc [ ("username", `String username); _ ] -> username
            | _ -> failwith "invalid message json"
          in
          Lwt.bind
            (User.username_exists (match_user input_json) ())
            (fun q ->
              match q with
              | Ok true ->
                  Lwt.bind
                    (User.email_of_user (match_user input_json) ())
                    (fun r ->
                      match r with
                      | Ok a ->
                          Lwt.bind
                            (Storage.add_msg a "all"
                               (let match_message y =
                                  match y with
                                  | `Assoc
                                      [
                                        _; ("message", `String message);
                                      ] ->
                                      message
                                  | _ -> failwith "invalid message json"
                                in
                                match_message input_json)
                               ())
                            (fun s ->
                              match s with
                              | Ok () ->
                                  Lwt.bind
                                    (Storage.add_msg
                                       "eaxiwojcsblxvyeijz@kvhrr.com"
                                       "all"
                                       (let match_message z =
                                          match z with
                                          | `Assoc
                                              [
                                                _;
                                                ( "message",
                                                  `String message );
                                              ] ->
                                              message
                                          | _ ->
                                              failwith
                                                "invalid message json"
                                        in
                                        Bot.bot_response
                                          (match_message input_json)
                                          4)
                                       ())
                                    (fun t ->
                                      match t with
                                      | Ok () ->
                                          Lwt.return
                                            (Response.make ~status:`OK
                                               ())
                                      | Error e -> Lwt.fail (failwith e))
                              | Error e -> Lwt.fail (failwith e))
                      | Error e -> Lwt.fail (failwith e))
              | Ok false -> failwith "no users"
              | Error e -> Lwt.fail (failwith e))))

let bind_functions fun1 fun2 =
  Lwt.bind fun1 (fun a ->
      match a with Ok () -> fun2 | Error e -> Lwt.fail (failwith e))

let create_db =
  App.get "/create" (fun _ ->
      Lwt.bind (User.migrate ()) (fun a ->
          match a with
          | Ok () ->
              Lwt.bind (User.username_exists "Bob-bot" ()) (fun d ->
                  match d with
                  | Ok true ->
                      Lwt.bind
                        (User.add_usr "eaxiwojcsblxvyeijz@kvhrr.com"
                           "asldfjaskdl" "Bob-bot" ()) (fun c ->
                          match c with
                          | Ok () ->
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
                  | Ok false ->
                      bind_functions (Storage.migrate ())
                        (bind_functions (Contacts.migrate ())
                           (bind_functions
                              (Conversations.migrate ())
                              (bind_functions
                                 (UserConversation.migrate ())
                                 (Lwt.return
                                    (Response.make ~status:`OK ())))))
                      (* Lwt.bind (Storage.migrate ()) (fun e -> match e
                         with | Ok () -> Lwt.return (Response.make
                         ~status:`OK ()) | Error e -> Lwt.fail (failwith
                         e)) *)
                  | Error e -> Lwt.fail (failwith e))
          | Error e -> Lwt.fail (failwith e)))

let close_db =
  App.get "/close" (fun _ ->
      bind_functions (User.rollback ())
        (bind_functions (Storage.rollback ())
           (bind_functions (Contacts.rollback ())
              (bind_functions
                 (Conversations.rollback ())
                 (bind_functions
                    (UserConversation.rollback ())
                    (Lwt.return (Response.make ~status:`OK ()))))))
      (* Lwt.bind (User.rollback ()) (fun a -> match a with | Ok () ->
         Lwt.bind (Storage.rollback ()) (fun b -> match b with | Ok ()
         -> Lwt.return (Response.make ~status:`OK ()) | Error e ->
         Lwt.fail (failwith e)) | Error e -> Lwt.fail (failwith e))) *))

(* cors creates a middleware that fixes cors policy errors that are
   encountered when trying to make requests to the server*)
let cors =
  Middleware.allow_cors
    ~origins:[ "http://localhost:8080" ]
    ~credentials:true ()

(* static_content creates a middleware that serves the frontend static
   files so that the app can be accessed from the browser *)
(*let static_content = Middleware.static_unix ~local_path:(Unix.realpath
  "frontend/dist") ()*)

(* Creates the app with the above functions *)
let _ =
  App.empty |> App.middleware cors |> create_db |> close_db
  (*|> App.middleware static_content*)
  |> register_user
  |> login_user |> read_messages |> post_messages |> post_messages_bot
  (* |> add_contact |> get_contacts |> get_conversations |>
     make_favorite *)
  |> App.run_command
