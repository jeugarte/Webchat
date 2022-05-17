(*open Caqti_lwt*)
(*open Caqti_driver_postgresql*)
open Lwt.Infix

module Db : Caqti_lwt.CONNECTION =
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432")
     >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type message = {
  senderid : string;
  convoid : string;
  msg : string;
}

type sender_message = {
  senderid : int;
  msg : string;
}

type recipient_message = {
  convoid : int;
  msg : string;
}

module Message = struct
  let create_msglst =
    (unit ->. unit)
    @@ {eos| 
      CREATE TABLE IF NOT EXISTS msglst (
        id SERIAL PRIMARY KEY,
        senderid TEXT NOT NULL,
        convoid TEXT NOT NULL,
        msg TEXT NOT NULL,
        timer timestamp
      )
    |eos}

  let drop_msglst = (unit ->. unit) @@ "DROP TABLE msglst"

  (*NOT IMPLEMENTED YET BUT USERS WILL HAVE A LIST OF MESSGAES, SO IT IS
    A ONE OF MANY RELATIONSHIP WHERE ONE USER CAN HAVE MULTIPLE
    MESSAGES. THATS WHEN WE USE AN ASSOCIATIVE TABLE BUT ILL LOOK INTO
    THAT*)

  let add_msg_sql senderid convoid msg =
    (unit ->. unit)
    @@ "INSERT INTO msglst (senderid, convoid, msg) VALUES ('"
    ^ senderid ^ "', '" ^ convoid ^ "', '" ^ msg ^ "')"

  let read_msg_of_sender_sql =
    string
    ->* Caqti_type.custom
          ~encode:(fun ({ senderid; msg } : sender_message) ->
            Ok (senderid, msg))
          ~decode:(fun (senderid, msg) -> Ok { senderid; msg })
          Caqti_type.(tup2 int string)
    @@ "SELECT * FROM msglst WHERE senderid = ?"

  let read_msg_of_recipient_sql =
    string
    ->* Caqti_type.custom
          ~encode:(fun ({ convoid; msg } : recipient_message) ->
            Ok (convoid, msg))
          ~decode:(fun (convoid, msg) -> Ok { convoid; msg })
          Caqti_type.(tup2 int string)
    @@ "SELECT * FROM msglst WHERE convoid = ?"

  (* let read_conversation_sql = string ->* (Caqti_type.custom
     ~encode:(fun ({senderid; convoid; msg} : message)-> Ok (senderid,
     convoid, msg)) ~decode:(fun (senderid, convoid, msg) -> Ok
     {senderid; convoid; msg}) Caqti_type.(tup3 int int string)) @@
     "SELECT * FROM msglst WHERE senderid = ? AND convoid = ?" *)
  let read_all_sql =
    unit
    ->* Caqti_type.custom
          ~encode:(fun ({ senderid; convoid; msg } : message) ->
            Ok (senderid, convoid, msg))
          ~decode:(fun (senderid, convoid, msg) ->
            Ok { senderid; convoid; msg })
          Caqti_type.(tup3 string string string)
    @@ "SELECT senderid, convoid, msg FROM msglst"
end

let migrate () =
  let open Message in
  Lwt.bind (Db.exec create_msglst ()) (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let rollback () =
  let open Message in
  Lwt.bind (Db.exec drop_msglst ()) (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let add_msg senderid convoid msg () =
  let open Message in
  Lwt.bind
    (Db.exec (add_msg_sql senderid convoid msg) ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let read_sent_msgs senderid () =
  let open Message in
  Lwt.bind
    (Db.iter_s read_msg_of_sender_sql
       (fun data -> Lwt_io.print (data.msg ^ "\n") >>= Lwt.return_ok)
       senderid)
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> failwith (Caqti_error.show error))

let read_recieved_msgs convoid () =
  let open Message in
  Lwt.bind
    (Db.iter_s read_msg_of_recipient_sql
       (fun data -> Lwt_io.print (data.msg ^ "\n") >>= Lwt.return_ok)
       convoid)
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> failwith (Caqti_error.show error))

(* let read_conversation_msgs senderid convoid () = let open Message in
   Lwt.bind ((Db.collect_list (read_conversation_sql) senderid) @@
   (Db.collect_list (read_conversation_sql) senderid)) (fun result ->
   match result with | Ok data -> Lwt.return (Ok data) | Error error ->
   failwith (Caqti_error.show error)) *)

(* TODO let read_parsed_convo_msgs senderid convoid () = let open
   Message in let sender = read_sent_msgs senderid in let recipient =
   read_received_msgs convoid in sender @@ recipient (this is how it
   should work in theory) *)

let read_all () =
  let open Message in
  Lwt.bind
    (Db.fold read_all_sql
       (fun { senderid; convoid; msg } acc ->
         { senderid; convoid; msg } :: acc)
       () [])
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> failwith (Caqti_error.show error))
