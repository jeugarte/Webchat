open Lwt.Infix

module Db : Caqti_lwt.CONNECTION = 
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432") >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type message = {
  senderid : string;
  recipientid : string;
  msg : string
}

type sender_message = {
  senderid : int;
  msg : string
}

type recipient_message = {
  recipientid : int;
  msg : string
}

module Message = struct

  let create_msglst = unit ->. unit @@ 
    {eos| 
      CREATE TABLE IF NOT EXISTS msglst (
        id SERIAL PRIMARY KEY,
        senderid TEXT NOT NULL,
        recipientid TEXT NOT NULL,
        msg TEXT NOT NULL,
        timer timestamp
      )
    |eos}

  let drop_msglst = unit ->. unit @@
    "DROP TABLE msglst"

(*NOT IMPLEMENTED YET BUT USERS WILL HAVE A LIST OF MESSGAES, SO IT IS A ONE OF MANY RELATIONSHIP WHERE ONE USER CAN HAVE MULTIPLE 
MESSAGES. THATS WHEN WE USE AN ASSOCIATIVE TABLE BUT ILL LOOK INTO THAT*)

  let add_msg_sql senderid recipientid msg = unit ->. unit @@ 
  "INSERT INTO msglst (senderid, recipientid, msg) VALUES ('" ^ senderid ^ "', '" ^ recipientid ^ "', '" ^ msg ^ "')"

  let read_msg_of_sender_sql = string ->* (Caqti_type.custom ~encode:(fun ({senderid; msg} : sender_message) -> 
    Ok (senderid, msg)) 
    ~decode:(fun (senderid, msg) -> Ok {senderid; msg}) Caqti_type.(tup2 int string)) @@ 
    "SELECT * FROM msglst WHERE senderid = ?"

  let read_msg_of_recipient_sql = string ->* (Caqti_type.custom ~encode:(fun ({recipientid; msg} : recipient_message) -> 
    Ok (recipientid, msg)) 
    ~decode:(fun (recipientid, msg) -> Ok {recipientid; msg}) Caqti_type.(tup2 int string)) @@ 
    "SELECT * FROM msglst WHERE recipientid = ?"

    (*
  let read_conversation_sql = string ->* (Caqti_type.custom ~encode:(fun ({senderid; recipientid; msg} : message)-> 
    Ok (senderid, recipientid, msg)) 
    ~decode:(fun (senderid, recipientid, msg) -> Ok {senderid; recipientid; msg}) Caqti_type.(tup3 int int string)) @@ 
    "SELECT * FROM msglst WHERE senderid = ? AND recipientid = ?"
    *)
  let read_all_sql = unit ->* (Caqti_type.custom ~encode:(fun ({senderid; recipientid; msg} : message)-> 
    Ok (senderid, recipientid, msg)) 
    ~decode:(fun (senderid, recipientid, msg) -> Ok {senderid; recipientid; msg}) Caqti_type.(tup3 string string string)) @@ 
    "SELECT senderid, recipientid, msg FROM msglst"
end

let migrate () = let open Message in
   Lwt.bind (Db.exec create_msglst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let rollback () = let open Message in
    Lwt.bind (Db.exec drop_msglst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let add_msg senderid recipientid msg () = let open Message in
  Lwt.bind (Db.exec (add_msg_sql senderid recipientid msg) ()) (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let read_sent_msgs senderid () = let open Message in
  Lwt.bind (Db.iter_s (read_msg_of_sender_sql) (fun data -> Lwt_io.print (data.msg^"\n") >>= 
  Lwt.return_ok) senderid) (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> failwith (Caqti_error.show error))

let read_recieved_msgs recipientid () = let open Message in
  Lwt.bind (Db.iter_s (read_msg_of_recipient_sql) (fun data -> Lwt_io.print (data.msg^"\n") >>= 
  Lwt.return_ok) recipientid) (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> failwith (Caqti_error.show error))

  (*
let read_conversation_msgs senderid recipientid () = let open Message in
  Lwt.bind ((Db.collect_list (read_conversation_sql) senderid) @@ (Db.collect_list (read_conversation_sql) senderid))  (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> failwith (Caqti_error.show error))
*)

(* TODO 
let read_parsed_convo_msgs senderid recipientid () = let open Message in
  let sender = read_sent_msgs senderid in
    let recipient = read_received_msgs recipientid in
      sender @@ recipient (this is how it should work in theory) 
*)

let read_all () = let open Message in
  Lwt.bind (Db.fold (read_all_sql) (fun {senderid; recipientid; msg} acc -> 
  {senderid; recipientid; msg} :: acc) () []) (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> failwith (Caqti_error.show error))
