open Lwt.Infix


module Db : Caqti_lwt.CONNECTION = 
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432") >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

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

module UserQuery = struct
  
  let create_usrlst = unit ->. unit @@ 
    {eos| 
      CREATE TABLE IF NOT EXISTS usrlst (
        id SERIAL PRIMARY KEY,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        username TEXT NOT NULL
      )
    |eos}

  let drop_usrlst = unit ->. unit @@
    "DROP TABLE usrlst"

  let query_email email = unit ->! (Caqti_type.custom ~encode:(fun boolean -> Ok boolean) 
  ~decode:(fun boolean -> Ok boolean) Caqti_type.bool) @@ 
    "select exists(select 1 from usrlst where email = '" ^ email ^ "') AS exists"
  
  let query_username username = unit ->! (Caqti_type.custom ~encode:(fun boolean -> Ok boolean) 
  ~decode:(fun boolean -> Ok boolean) Caqti_type.bool) @@ 
    "select exists(select 1 from usrlst where username = '" ^ username ^ "') AS exists"

  let add_usr_sql email password username = unit ->. unit @@ 
    "INSERT INTO usrlst (email, password, username) VALUES ('" ^ email ^ "', '" ^ password ^ "', '" ^ username ^ "')"
  
  let get_username email = unit ->! (Caqti_type.custom ~encode:(fun s -> Ok s) 
  ~decode:(fun s -> Ok s) Caqti_type.string) @@ 
    "select username from usrlst where email = '" ^ email ^ "'"
  
  let get_email username = unit ->! (Caqti_type.custom ~encode:(fun s -> Ok s) 
  ~decode:(fun s -> Ok s) Caqti_type.string) @@ 
    "select email from usrlst where username = '" ^ username ^ "'"

  let query_password email password username = unit ->! (Caqti_type.custom ~encode:(fun boolean -> Ok boolean) 
  ~decode:(fun boolean -> Ok boolean) Caqti_type.bool) @@ 
    "select exists(select 1 from usrlst where password = '" ^ password ^ "' and (username = '" ^ username ^ "' or email = '" ^ email ^ "'))"
    
  (*let read_user_sql = string ->* (Caqti_type.custom ~encode:(fun ({email; password; username} : user) -> 
    Ok (email, password, username)) 
    ~decode:(fun (email, password, username) -> Ok {email; password; username}) Caqti_type.(tup3 string string string)) @@ 
    "SELECT * FROM usrlst WHERE email = ? AND password = ? AND username = ?"
*)
end

let migrate () = let open UserQuery in
   Lwt.bind (Db.exec create_usrlst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let rollback () = let open UserQuery in
    Lwt.bind (Db.exec drop_usrlst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let add_usr email password username () = let open UserQuery in
  Lwt.bind (Db.exec (add_usr_sql email password username) ()) (fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let email_exists email () = let open UserQuery in 
  Lwt.bind (Db.find (query_email email) ())(fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let username_exists username () = let open UserQuery in 
  Lwt.bind (Db.find (query_username username) ())(fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let user_of_email email () = let open UserQuery in 
  Lwt.bind (Db.find (get_username email) ())(fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let email_of_user username () = let open UserQuery in 
  Lwt.bind (Db.find (get_email username) ())(fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))
  

let check_password email password username () = let open UserQuery in 
  Lwt.bind (Db.find (query_password email password username) ())(fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))





