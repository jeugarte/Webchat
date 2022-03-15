open Opium

let users = ref []

let register_user =  
  App.post "/register" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun user_json -> let user_info = user_json |> User.user_of_yojson in 
    let matchUser x = 
      let rec matchUserList (y : User.user list)= match y with
    | [] -> x := user_info :: !x; Lwt.return (Response.of_plain_text ("Success"))
    | {username;email;_} :: t -> if email = user_info.email then (x := !x; Lwt.return (Response.of_plain_text("Email taken"))) else if username = user_info.username then (x := !x; Lwt.return (Response.of_plain_text("Username taken")))else matchUserList (t)
  in matchUserList !x in
       matchUser users))

let login_user = 
  App.post "/login" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun user_json -> let user_info =
      user_json |> User.user_of_yojson in 
      let rec matchUser (x : User.user list) = match x with
      | [] -> Lwt.return (Response.of_plain_text ("No User"))
      | {username;password;email} :: t -> if username = user_info.username && password = user_info.password then Lwt.return (Response.of_plain_text (email)) else if email = user_info.email && password = user_info.password then Lwt.return (Response.of_json(`Assoc[("email", `String email);("username", `String username)])) else matchUser t
    in matchUser !users))

let get_users = 
  App.get "/users" (fun _ -> 
    let users = !users in
    let rec json x = match x with
    | [] -> []
    | h :: t -> User.yojson_of_user (h) :: json t
  in
    Lwt.return (Response.of_json (`Assoc [ ("users", `List (json users))])))

let messages = ref []

let read_messages = 
  App.get "/getMessages" (fun _ -> 
    let messages = !messages in
    let rec json (x : Message.message list) = match x with
    | [] -> []
    | h1 :: t1 -> `Assoc [("username", `String (let rec find_user (y : User.user list) = match y with
    | [] -> failwith "no users"
    | h2 :: t2 -> if h2.email = h1.userid then h2.username else find_user t2 
  in find_user !users)); 
    ("message", `String h1.msg)] :: json t1
  in
    Lwt.return (Response.of_json (`Assoc [ ("data", `List (json messages))])))

let post_messages = 
  App.post "/postMessage" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun input_json ->
    (let rec input_message (x : User.user list) : Message.message = match x with 
    | [] -> failwith "no users"
    | h :: t -> if h.username = (let match_user y = match y with
      | `Assoc [ ("username", `String username); _ ] 
        -> username
      | _ -> failwith "invalid message json" in match_user input_json) then 
        {userid = h.email; msg = (let match_message z = match z with
      | `Assoc [ _ ; ("message", `String message)] 
        -> message
      | _ -> failwith "invalid message json" in match_message input_json)} 
    else 
        input_message t in messages := input_message !users :: !messages); 
        Lwt.return (Response.make ~status: `OK ())))
    
(*
let print_person_handler req =
  let username = Router.param req "username" in
  let password = Router.param req "password" in
  let user = { User.username; password } |> User.yojson_of_t in
  Lwt.return (Response.of_json user)


let update_person_handler req =
  let open Lwt.Syntax in
  let+ json = Request.to_json_exn req in
  let user = User.t_of_yojson json in
  Logs.info (fun m -> m "Received user: %s" user.User.username);
  Response.of_json (`Assoc [ "message", `String "Person saved" ])


let streaming_handler req =
  let length = Body.length req.Request.body in
  let content = Body.to_stream req.Request.body in
  let body = Lwt_stream.map String.uppercase_ascii content in
  Response.make ~body:(Body.of_stream ?length body) () |> Lwt.return


let print_param_handler req =
  Printf.sprintf "Hello YOO, %s\n" (Router.param req "username")
  |> Response.of_plain_text
  |> Lwt.return
*)

let cors = Middleware.allow_cors ~origins:["*"] ~credentials:false ()

let _ =
  App.empty
  |> App.middleware cors
  |> get_users
  |> register_user
  |> login_user
  (* |> App.post "/hello/stream" streaming_handler
  |> App.get "/hello/:username" print_param_handler
  |> App.get "/user/:username/:password" print_person_handler
  |> App.patch "/user" update_person_handler *)
  |> read_messages
  |> post_messages
  |> App.run_command

