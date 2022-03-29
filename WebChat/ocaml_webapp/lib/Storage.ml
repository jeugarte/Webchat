(*open Caqti_lwt*)
(*open Caqti_driver_postgresql*)
open Lwt.Infix

module Db : Caqti_lwt.CONNECTION = 
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432") >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type message = {
  userid : string;
  msg : string
}

let create_msglst = unit ->. unit @@ 
{eos| 
  CREATE TABLE IF NOT EXISTS msglst (
    userid text NOT NULL,
    msg text NOT NULL
  )
|eos}

let add_msg_sql userid msg = unit ->. unit @@ "INSERT INTO msglst (userid, msg) VALUES ('" ^ userid ^ "', '" ^ msg ^ "')"

let read_msg_sql = string ->* (Caqti_type.custom ~encode:(fun {userid; msg} -> Ok (userid, msg)) ~decode:(fun (userid, msg) -> Ok {userid; msg}) Caqti_type.(tup2 string string)) @@ "SELECT * FROM msglst WHERE userid = ?"

let read_all_sql = unit ->* (Caqti_type.custom ~encode:(fun {userid; msg} -> Ok (userid, msg)) ~decode:(fun (userid, msg) -> Ok {userid; msg}) Caqti_type.(tup2 string string)) @@ "SELECT * FROM msglst"


let migrate () =
   Lwt.bind (Db.exec create_msglst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))


let add_msg userid msg () = Lwt.bind (Db.exec (add_msg_sql userid msg) ()) (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let read_msgs userid () = Lwt.bind (Db.iter_s (read_msg_sql) (fun data -> Lwt_io.print (data.msg^"\n") >>= Lwt.return_ok) userid) (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> failwith (Caqti_error.show error))

  let read_all () = Lwt.bind (Db.iter_s (read_all_sql) (fun data -> Lwt_io.print (data.userid^": "^data.msg^"\n") >>= Lwt.return_ok) ()) (fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> failwith (Caqti_error.show error))

