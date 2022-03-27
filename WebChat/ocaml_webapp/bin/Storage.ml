(**open Caqti_lwt
open Caqti_driver_postgresql *)
open Lwt.Infix

module Db : Caqti_lwt.CONNECTION = 
(val Caqti_lwt.connect (Uri.of_string "postgresql://") >>= Caqti_lwt.or_fail |> Lwt_main.run)


open Caqti_request.Infix
open Caqti_type.Std

open Message 
let message = let encode {userid; msg} = Ok (userid, msg) in
let decode (userid, msg) = Ok {userid; msg} in
let rep = Caqti_type.(tup2 string string) in 
custom ~encode ~decode rep

let create_msglst = unit ->. unit @@ 
{eos| 
  CREATE TEMPORARY TABLE msglst (
    userid : text NOT NULL,
    msg : text NOT NULL
  )
|eos}

let insert_msg = tup2 string string ->. unit @@
"INSERT INTO msglst (userid,msg) VALUES (?, ?)"

let read_msgs = unit ->? unit @@ 
"SELECT msg FROM msglst WHERE userid = ?"
