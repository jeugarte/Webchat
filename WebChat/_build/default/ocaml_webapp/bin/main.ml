open Opium
(*
module User = struct
  type t =
    { username : string
    ; password : string
    }
  let yojson_of_t t = `Assoc [ ("username", `String t.username); 
  ("password", `String t.password) ]

  let t_of_yojson yojson =
    match yojson with
    | `Assoc [ ("username", `String username); ("password", `String password) ] 
    -> { username; password }
    | _ -> failwith "invalid user json"
  
end
*)
module Message = struct
  type message = {username : string; msg : string}
  let yojson_of_t t = `Assoc [ ("username", `String t.username); ("message", 
  `String t.msg) ]
  let t_of_yojson yojson =
    match yojson with
    | `Assoc [ ("username", `String username); ("message", `String msg) ] 
    -> { username; msg }
    | _ -> failwith "invalid message json"
end

let messages = ref []

let read_messages = 
  App.get "/messages" (fun _ -> 
    let messages = !messages in
    let rec json x = match x with
    | [] -> []
    | h :: t -> Message.yojson_of_t (h) :: json t
  in
    Lwt.return (Response.of_json (`Assoc [ ("data", `List (json messages))])))

let post_messages = 
  App.post "/messages" (fun request -> 
    Lwt.bind (Request.to_json_exn request) (fun input_json ->
    let input_message = input_json |> Message.t_of_yojson in
    messages := input_message :: !messages; Lwt.return 
    (Response.make ~status: `OK ())))
    
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

let cors = Middleware.allow_cors ~origins:["http://localhost:8080"] ~credentials:true ()

let _ =
  App.empty
  |> App.middleware cors
  (* |> App.post "/hello/stream" streaming_handler
  |> App.get "/hello/:username" print_param_handler
  |> App.get "/user/:username/:password" print_person_handler
  |> App.patch "/user" update_person_handler *)
  |> read_messages
  |> post_messages
  |> App.run_command

