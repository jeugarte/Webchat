open Opium
open Ocaml_webapp

(* register_user creates a post request that takes in a json containing the email, password, username of a new user and outputs "Email taken" if users contains the email already, "Username taken" if users contains the username already, and "Success" if the information can be used to create a user that is added to users *)
let register_user =  
  App.post "/register" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun user_json -> let user_info = user_json |> User.user_of_yojson in 
    Lwt.bind (User.email_exists user_info.email ()) (fun x -> match x with
    | Ok true -> Lwt.return (Response.of_plain_text ("Email taken"))
    | Ok false -> 
      Lwt.bind (User.username_exists user_info.username ()) (fun y -> match y with
      | Ok true -> Lwt.return (Response.of_plain_text ("Username taken"))
      | Ok false -> Lwt.bind (User.add_usr user_info.email user_info.password user_info.username ())
                    (fun _ -> Lwt.return (Response.of_plain_text ("Success")))
      | Error e -> Lwt.fail (failwith e))
    | Error e -> Lwt.fail (failwith e))
  ) 
)

(* login_user creates a post request that takes in the json containing the information for a user x and outputs "No User" if x is not in users and a json containing the email and username of x otherwise *)
let login_user = 
  App.post "/login" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun user_json -> let user_info =
      user_json |> User.user_of_yojson in 
      Lwt.bind (User.check_password user_info.email user_info.password user_info.username ())(
        fun x -> match x with
        | Ok true -> Lwt.bind (User.email_exists user_info.email ()) (fun y -> match y with
          | Ok true -> Lwt.bind (User.user_of_email user_info.email ()) (fun z -> match z with 
            | Ok a -> Lwt.return (Response.of_json(`Assoc[("email", `String user_info.email);("username", `String a)]))
            | Error e -> Lwt.fail (failwith e))
          | Ok false -> Lwt.bind (User.email_of_user user_info.username ()) (fun b -> match b with 
          | Ok c -> Lwt.return (Response.of_json(`Assoc[("email", `String c);("username", `String user_info.username)]))
          | Error e -> Lwt.fail (failwith e))
          | Error e -> Lwt.fail (failwith e))
        | Ok false -> Lwt.return (Response.of_plain_text ("No User"))
        | Error e -> Lwt.fail (failwith e)
      )
    ))

(* get_users creates a get request that outputs users for testing purposes *)
(*
let get_users = 
  App.get "/users" (fun _ -> 
    let users = !users in
    let rec json x = match x with
    | [] -> []
    | h :: t -> User.yojson_of_user (h) :: json t
  in
    Lwt.return (Response.of_json (`Assoc [ ("users", `List (json users))])))
*)

(* read_messages creates a get request that outputs a json containing the list of messages as objects with username and the message
Raises: "no users" if the userid associated with a message is not an email in users (this should not occur as userid should be immutable after registration) *)
let read_messages = 
  App.get "/getMessages" (fun _ -> 
    Lwt.bind (Storage.read_all ()) (fun x -> match x with
    | Ok a -> let messages = a in
    let rec json (x : Storage.message list) = match x with
    | [] -> Lwt.return []
    | h1 :: t1 -> 
      Lwt.bind (User.email_exists h1.senderid ()) (fun y -> match y with 
    | Ok true -> Lwt.bind (User.user_of_email h1.senderid ()) (fun z -> match z with
      | Ok b -> Lwt.bind (json t1) (fun s -> match s with 
        | d -> Lwt.return (`Assoc [("username", `String (b))
        ;("message", `String h1.msg)] :: d)
      )
      | Error e -> Lwt.fail (failwith e))
    | Ok false -> Lwt.fail (failwith "no users")
    | Error e -> Lwt.fail (failwith e))  
  in
    Lwt.bind (json messages) (fun a -> match a with
    | c -> Lwt.return (Response.of_json (`Assoc [ ("data", `List (c))]))
    )
  | Error e -> Lwt.fail (failwith e))
  )

(* post_messages creates a post request that takes in a json containing the username and message of a message and adds a message with the userid/email and message as fields to messages 
Raises: "no users" if the username in the json does not match the current username of any user in users 
"invalid message json" if the input json does not contain username and message *)
let post_messages = 
  App.post "/postMessage" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun input_json ->
      let match_user x = match x with 
      | `Assoc [ ("username", `String username); _ ] -> username
      | _ -> failwith "invalid message json"
    in Lwt.bind (User.username_exists (match_user input_json) ()) (fun q -> match q with
      | Ok true -> Lwt.bind (User.email_of_user (match_user input_json) ()) (fun r -> match r with
        | Ok a -> Lwt.bind (Storage.add_msg a "all" 
        (let match_message y = match y with 
          | `Assoc [ _ ; ("message", `String message)] 
          -> message
          | _ -> failwith "invalid message json" in match_message input_json) () ) (fun s -> match s with
            | Ok () -> Lwt.return (Response.make ~status: `OK ()) 
            | Error e -> Lwt.fail (failwith e))
       | Error e -> Lwt.fail (failwith e))
      | Ok false -> failwith "no users"
      | Error e -> Lwt.fail (failwith e)
    )
    ))

let bot_response s = 
  let rec first_punc l1 = match l1 with
  | [] -> 1
  | h :: t -> (match h.[(String.length h) - 1] with
    | '.' -> 2
    | '!' -> 3
    | '?' -> 4
    | _ -> first_punc t
  ) in 
  let rec key_word l2 = match l2 with
  | [] -> 1
  | h :: t -> (match h with 
    | "joke" -> 2
    | "you" -> 3
    | _ -> key_word t)
  in 
  let first_word l3 = match List.hd l3 with
  | "i''m" -> 1
  | "does" -> 2
  | "are" -> 2
  | "is" -> 2
  | "was" -> 2
  | "have" -> 2
  | "do" -> 2
  | "did" -> 2
  | "can" -> 2
  | "should" -> 2
  | "may" -> 2
  | "who" -> 3
  | "what" -> 3
  | "when" -> 3
  | "where" -> 3
  | "why" -> 3
  | "how" -> 3
  | "which" -> 3
  | "what's" -> 3
  | "how's" -> 3
  | "when's" -> 3
  | "who's" -> 3
  | _ -> 4
  in
  let strlist = List.filter (fun a -> a <> "") (String.split_on_char ' ' (s |> String.trim |> String.lowercase_ascii))
in match (first_punc strlist, key_word strlist, first_word strlist) with
| (_,_,1) -> (List.fold_left (fun a b -> a ^ " " ^ b) "Hi" (List.tl strlist)) ^ ". I'm Bob!"
| (4,_,2) -> (let n = Random.int 3 in match n with
  | 0 -> "Yes"
  | 1 -> "No"
  | _ -> "Maybe")
| (1,3,2) -> (let n = Random.int 3 in match n with
  | 0 -> "Yes"
  | 1 -> "No"
  | _ -> "Maybe")
| (_,_,3) -> (let n = Random.int 4 in match n with
  | 0 -> "Huh? Why?"
  | 1 -> "What?"
  | 2 -> "Why?"
  | _ -> "I don't know")
| (_,2,_) -> (let n = Random.int 4 in match n with
  | 0 -> "Once upon a time, there was a farmer who really liked his tractors. 
  He would ride a tractor in his fields for hours at a time and polish them so 
  that they were spick and span. He even had tractor posters in his room! 
  However, the one thing he liked more than his tractors was his wife. 
  Understandably, of course, as he was a family man. Unfortunately, one day, 
  tragedy struck. His wife was killed by a tractor. The farmer was devastated 
  and he could never look at his tractors in the same way again. He got rid of 
  every single one of his tractors and he even ripped up the tractor posters in 
  his room. However, as time past, the pain of his wife''s passing slowly faded 
  away and he found himself in the dating scene again. One day, he was at a 
  restaurant with his date when he heard a loud boom from the kitchen. Thick black
  plumes of smoke started filling the restaurant and panic ensued as everyone 
  struggled to breath. At this point, the farmer calmly stood up and said I got this! 
  as he opened his mouth and breathed in all of the smoke in the building. He then
  walked to the door and exhaled all of the smoke. When he came back to his seat,
  his date was very impressed and she asked him, How did you manage to do that?
  The farmer responded, Oh, it''s because I''m an ex-tractor fan."
  | 1 -> "How do you kiss someone at the end of the world? On the apocalypse."
  | 2 -> "Once upon a time, there was a couple -- a man named Pablo and his wife Michelle. 
  One day, one of Pablo''s good friends invited him to a Halloween costume party. 
  Pablo was very excited and agree to go, but he had one problem ... he didn''t 
  have a costume yet. So, as the date of the party drew closer and closer, Pablo 
  visited Party City and many other stores to find the perfect costume. But, he
  couldn''t find a costume that met his expectations. Indeed, he wanted a matching
  costume with his wife. Finally, Pablo woke up on the day of the party realizing
  that he still didn''t have a proper costume. Luckily, right before the party was 
  supposed to start, Pablo came up with a brilliant idea for a costume. And so, he
  went to the party very proud of himself. When he showed up to the party, his friend
  looked him up and down and asked, \"Hey Pablo, what''re you supposed to be?\" \"Oh,\" 
  said Pablo \"I''m a turtle.\" \"So what''s your wife doing on your back?\" asked his 
  friend quizzically. To which, Pablo responded, \"Oh, that''s Michelle.\""
  | _ -> "What''s the difference between a steak and a meteorite? A steak is pretty
  meaty but the other is a little meteor.")
| (3,_,_) -> (let n = Random.int 4 in match n with
  | 0 -> "Nice!"
  | 1 -> "Cool!"
  | 2 -> "Alrighty."
  | _ -> "Big!")
| (2,_,_) -> (let n = Random.int 4 in match n with
| 0 -> "Dang."
| 1 -> "Hmm."
| 2 -> "*Thinking*"
| _ -> "Wow!")
| (_,_,_) -> "Umm"
let post_messages_bot = 
  App.post "/postMessageBot" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun input_json ->
      let match_user x = match x with 
        | `Assoc [ ("username", `String username); _ ] -> username
        | _ -> failwith "invalid message json"
      in Lwt.bind (User.username_exists (match_user input_json) ()) (fun q -> match q with
        | Ok true -> Lwt.bind (User.email_of_user (match_user input_json) ()) (fun r -> match r with
          | Ok a -> (Lwt.bind (Storage.add_msg a "all" 
          (let match_message y = match y with 
            | `Assoc [ _ ; ("message", `String message)] 
            -> message
            | _ -> failwith "invalid message json" in match_message input_json) () ) (fun s -> match s with
              | Ok () -> (Lwt.bind (Storage.add_msg "eaxiwojcsblxvyeijz@kvhrr.com" "all"
                (let match_message z = match z with
                | `Assoc [ _ ; ("message", `String message)] 
                -> message
                | _ -> failwith "invalid message json" in bot_response(match_message input_json)) ()) (fun t -> match t with 
                | Ok () -> Lwt.return (Response.make ~status: `OK ())
                | Error e -> Lwt.fail(failwith e)))
              | Error e -> Lwt.fail (failwith e)))
         | Error e -> Lwt.fail (failwith e))
        | Ok false -> failwith "no users"
        | Error e -> Lwt.fail (failwith e)
      )
      ))

let create_db = 
  App.get "/create" (fun _ -> 
    Lwt.bind (User.migrate ()) (fun a -> match a with
    | Ok () -> (Lwt.bind (User.add_usr "eaxiwojcsblxvyeijz@kvhrr.com" "asldfjaskdl" "Bob-bot" ()) (fun c -> match c with 
    | Ok () -> 
      (Lwt.bind (Storage.migrate ()) (fun b -> match b with
      | Ok () -> Lwt.return (Response.make ~status: `OK ())
      | Error e -> Lwt.fail (failwith e)))
    | Error e -> Lwt.fail (failwith e)))
    | Error e -> Lwt.fail (failwith e))
    )

let close_db = 
  App.get "/close" (fun _ -> 
    Lwt.bind (User.rollback ()) (fun a -> match a with
    | Ok () -> Lwt.bind (Storage.rollback ()) (fun b -> match b with
      | Ok () -> Lwt.return (Response.make ~status: `OK ())
      | Error e -> Lwt.fail (failwith e))
    | Error e -> Lwt.fail (failwith e))
    )

(* cors creates a middleware that fixes cors policy errors that are encountered when trying to make requests to the server*)
let cors = Middleware.allow_cors ~origins:["http://localhost:8080"] ~credentials:true ()

(* static_content creates a middleware that serves the frontend static files so that the app can be accessed from the browser *)
let static_content = Middleware.static_unix ~local_path:(Unix.realpath "frontend/dist") ()

(* Creates the app with the above functions *)
let _ =
  App.empty
  |> App.middleware cors
  |> create_db
  |> close_db
  |> App.middleware static_content
  |> register_user
  |> login_user
  |> read_messages
  |> post_messages
  |> post_messages_bot
  |> App.run_command

