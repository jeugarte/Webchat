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

let migrate () =
   Lwt.bind (Db.exec create_msglst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))
  
(*let add_msg = failwith "not implemented"
  (*tup2 string string ->. unit @@
"INSERT INTO msglst (userid,msg) VALUES (?, ?)"*)

let read_msgs = failwith "not implemented"
  (*unit ->? unit @@ 
"SELECT msg FROM msglst WHERE userid = ?"*)*)

