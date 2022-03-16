type user =
    { email: string
    ; password : string;
    username: string
    }

let yojson_of_user u = `Assoc [ ("email", `String u.email); 
  ("password", `String u.password); ("username", `String u.username) ]

let user_of_yojson yojson =
    match yojson with
    | `Assoc [ ("email", `String email); ("password", `String password); 
    ("username", `String username) ] 
    -> { email; password; username}
    | _ -> failwith "invalid user json"