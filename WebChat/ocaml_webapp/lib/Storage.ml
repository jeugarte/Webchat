(*open Caqti_lwt*)
(*open Caqti_driver_postgresql*)
open Lwt.Infix


module Db : Caqti_lwt.CONNECTION = 
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432") >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type message = {
  senderid : int;
  recipientid : int;
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

  type sql_sent_message = {
    (*senderid : int;
    recipientid : int;*)
    sendername : string;
    recipientname : string;
    msg : string;
  }

  let create_msglst = unit ->. unit @@ 
    {eos| 
      CREATE TABLE IF NOT EXISTS msglst (
        id INTEGER PRIMARY KEY,
        senderid INTEGER NOT NULL,
        recipientid INTEGER NOT NULL,
        sendername TEXT NOT NULL,
        recipientname TEXT NOT NULL,
        msg TEXT NOT NULL,
        timer timestamp
      )
    |eos}

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
  let read_all_sql = unit ->* (Caqti_type.custom ~encode:(fun ({sendername; recipientname; msg} : sql_sent_message)-> 
    Ok (sendername, recipientname, msg)) 
    ~decode:(fun (sendername, recipientname, msg) -> Ok {sendername; recipientname; msg}) Caqti_type.(tup3 string string string)) @@ 
    "SELECT * FROM msglst"
end

let migrate () = let open Message in
   Lwt.bind (Db.exec create_msglst ()) (fun result ->
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
  Lwt.bind (Db.iter_s (read_all_sql) (fun data -> Lwt_io.print 
  ("Message sent from " ^ data.sendername ^ " to "  ^ data.recipientname ^ ": " ^ data.msg ^ "\n") >>= 
  Lwt.return_ok) ()) (fun result ->
  match result with
  | Ok data -> Lwt.return (Ok data)
  | Error error -> failwith (Caqti_error.show error))


module User = struct
  
  (*
  let create_usrlst = unit ->. unit @@ 
    {eos| 
      CREATE TABLE IF NOT EXISTS usrlst (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        contactslist TEXT,
        creation date
      )
    |eos}
  
  let add_usr_sql username email password = unit ->. unit @@ 
  "INSERT INTO usrlst (username, email, password) VALUES ('" ^ username ^ "', '" ^ email ^ "', '" ^ password ^ "')"

  let read_username_and_email_sql = string ->* (Caqti_type.custom ~encode:(fun ({email; password; username} : user) -> 
    Ok (email, password, username)) 
    ~decode:(fun (email, password, username) -> Ok {email; password; username}) Caqti_type.(tup3 string string string)) @@ 
    "SELECT * FROM usrlst WHERE email = ? AND password = ? AND username = ?"
    *)
end