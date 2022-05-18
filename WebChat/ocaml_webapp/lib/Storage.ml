(*open Caqti_lwt*)
(*open Caqti_driver_postgresql*)
open Lwt.Infix

module Db : Caqti_lwt.CONNECTION =
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432")
     >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type message = {
  senderid : int;
  convoid : int;
  msg : string;
}

type message_str = {
  senderemail : string;
  convoid : int;
  msg : string;
}

type sender_message = {
  senderid : int;
  msg : string;
}

let message_of_yojson yojson =
  match yojson with
  | `Assoc
      [
        ("sender_email", `String senderemail);
        ("conversation_id", `Int convoid);
        ("message", `String msg);
      ] ->
      { senderemail; convoid; msg }
  | _ -> failwith "invalid convo id json"

module Message = struct
  let create_msglst =
    (unit ->. unit)
    @@ {eos| 
      CREATE TABLE IF NOT EXISTS msglst (
        id SERIAL PRIMARY KEY,
        senderid INT NOT NULL,
        convoid INT NOT NULL,
        msg TEXT NOT NULL
      )
    |eos}

  let drop_msglst = (unit ->. unit) @@ "DROP TABLE msglst"

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

  (* let read_msg_of_recipient_sql = string ->* Caqti_type.custom
     ~encode:(fun ({ convoid; msg } : recipient_message) -> Ok (convoid,
     msg)) ~decode:(fun (convoid, msg) -> Ok { convoid; msg })
     Caqti_type.(tup2 int string) @@ "SELECT * FROM msglst WHERE convoid
     = ?" *)

  let read_conversation_sql ccid =
    unit
    ->* Caqti_type.custom
          ~encode:(fun ({ senderid; convoid; msg } : message) ->
            Ok (senderid, convoid, msg))
          ~decode:(fun (senderid, convoid, msg) ->
            Ok { senderid; convoid; msg })
          Caqti_type.(tup3 int int string)
    @@ "SELECT senderid, convoid, msg FROM msglst WHERE convoid = '"
    ^ ccid ^ "'"

  let read_all_sql =
    unit
    ->* Caqti_type.custom
          ~encode:(fun ({ senderid; convoid; msg } : message) ->
            Ok (senderid, convoid, msg))
          ~decode:(fun (senderid, convoid, msg) ->
            Ok { senderid; convoid; msg })
          Caqti_type.(tup3 int int string)
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
    (Db.exec
       (add_msg_sql
          (string_of_int senderid)
          (string_of_int convoid) msg)
       ())
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

let read_conversation_msgs convoid () =
  let open Message in
  Lwt.bind
    (Db.fold
       (read_conversation_sql (string_of_int convoid))
       (fun { senderid; convoid; msg } acc ->
         { senderid; convoid; msg } :: acc)
       () [])
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> failwith (Caqti_error.show error))

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
