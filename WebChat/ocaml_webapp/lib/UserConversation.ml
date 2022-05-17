open Lwt.Infix

module Db : Caqti_lwt.CONNECTION =
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432")
     >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type users_conversation = {
  conversation_id : int;
  user_id : int;
}

module UserConversation = struct
  let create_userconvo =
    (unit ->. unit)
    @@ {eos|
      CREATE TABLE IF NOT EXISTS userconvolst (
        id SERIAL PRIMARY KEY,
        conversation_id INT NOT NULL,
        users_id INT NOT NULL
      )
    |eos}

  let drop_userconvolst = (unit ->. unit) @@ "DROP TABLE userconvolst"

  let add_userconvo convoid userid =
    (unit ->. unit)
    @@ "INSERT INTO userconvolst (convoid, userid) VALUES (" ^ convoid
    ^ ", " ^ userid ^ ")"

  let get_convoid_from_userid userid =
    unit
    ->! Caqti_type.custom
          ~encode:(fun s -> Ok s)
          ~decode:(fun s -> Ok s)
          Caqti_type.string
    @@ "SELECT conversation_id FROM userconvolst WHERE user_id = '"
    ^ userid ^ "'"

  let get_convoid_from_userid2 id =
    unit
    ->* Caqti_type.custom
          ~encode:
            (fun ({ conversation_id; user_id } : users_conversation) ->
            Ok (conversation_id, user_id))
          ~decode:(fun (conversation_id, user_id) ->
            Ok { conversation_id; user_id })
          Caqti_type.(tup2 int int)
    @@ "SELECT conversation_id, user_id FROM userconvolst WHERE userid \
        = '" ^ id ^ "'"

  let get_userid_from_convo convo =
    unit
    ->! Caqti_type.custom
          ~encode:(fun s -> Ok s)
          ~decode:(fun s -> Ok s)
          Caqti_type.string
    @@ "SELECT userid FROM userconvolst WHERE conversation_id = '"
    ^ convo ^ "'"
end

let migrate () =
  let open UserConversation in
  Lwt.bind (Db.exec create_userconvo ()) (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let rollback () =
  let open UserConversation in
  Lwt.bind (Db.exec drop_userconvolst ()) (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let insert_user_conversation convo_id user_id () =
  let open UserConversation in
  Lwt.bind
    (Db.exec
       (add_userconvo (string_of_int convo_id) (string_of_int user_id))
       ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let get_conversationid_from_userid id () =
  let open UserConversation in
  Lwt.bind
    (Db.find (get_convoid_from_userid (string_of_int id)) ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let read_conversations_given_user id () =
  let open UserConversation in
  Lwt.bind
    (Db.fold
       (get_convoid_from_userid2 (string_of_int id))
       (fun { conversation_id; user_id } acc ->
         { conversation_id; user_id } :: acc)
       () [])
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> failwith (Caqti_error.show error))

let get_userid_from_conversationid id () =
  let open UserConversation in
  Lwt.bind
    (Db.find (get_userid_from_convo (string_of_int id)) ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))
