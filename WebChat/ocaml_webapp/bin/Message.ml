type message = {username : string; msg : string}
let yojson_of_message t = `Assoc [ ("username", `String t.username); 
("message", `String t.msg) ]
let message_of_yojson yojson =
  match yojson with
  | `Assoc [ ("username", `String username); ("message", `String msg) ] 
    -> { username; msg }
  | _ -> failwith "invalid message json"