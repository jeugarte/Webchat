open Lwt.Infix

module Db : Caqti_lwt.CONNECTION =
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432")
     >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type contact = {
  user_contact_id : int;
  user_id : int;
  contact_id : int;
  favorite : bool;
}

type get_contact = {
  user_id : int;
  contact_id : int;
  favorite : bool;
}

module Contacts = struct
  let create_contactslst =
    (unit ->. unit)
    @@ {eos| 
      CREATE TABLE IF NOT EXISTS contactslst (
        id SERIAL PRIMARY KEY,
        userid INT NOT NULL,
        contactid INT NOT NULL,
        favorite BOOLEAN NOT NULL
      )
    |eos}

  let drop_contactslst = (unit ->. unit) @@ "DROP TABLE contactslst"

  let add_contact user contact fav =
    (unit ->. unit)
    @@ "INSERT INTO contactslst (userid, contactid, favorite) VALUES ("
    ^ user ^ ", " ^ contact ^ ", " ^ fav ^ ")"

  let get_contacts user =
    unit
    ->! Caqti_type.custom
          ~encode:(fun s -> Ok s)
          ~decode:(fun s -> Ok s)
          Caqti_type.string
    @@ "SELECT contactid FROM contactslst WHERE userid = " ^ user

  let get_contacts_of_userid id =
    unit
    ->* Caqti_type.custom
          ~encode:
            (fun ({ user_id; contact_id; favorite } : get_contact) ->
            Ok (user_id, contact_id, favorite))
          ~decode:(fun (user_id, contact_id, favorite) ->
            Ok { user_id; contact_id; favorite })
          Caqti_type.(tup3 int int bool)
    @@ "SELECT userid, contactid, favorite FROM contactslst WHERE \
        userid = " ^ id

  let make_favorite user contact =
    (unit ->. unit)
    @@ "UPDATE contactslst SET favorite = true WHERE userid = '" ^ user
    ^ "' AND contactid = '" ^ contact ^ "' AND favorite = false"

  let remove_favorite user contact =
    (unit ->. unit)
    @@ "UPDATE contactslst SET favorite = false WHERE userid = '" ^ user
    ^ "' AND contactid = '" ^ contact ^ "' AND favorite = true"

  let view_favorites user =
    unit
    ->! Caqti_type.custom
          ~encode:(fun s -> Ok s)
          ~decode:(fun s -> Ok s)
          Caqti_type.string
    @@ "SELECT contactid FROM contactslst WHERE userid = " ^ user
    ^ " AND favorite = true"

  let favorite_status user contact =
    unit
    ->! Caqti_type.custom
          ~encode:(fun s -> Ok s)
          ~decode:(fun s -> Ok s)
          Caqti_type.bool
    @@ "SELECT favorite FROM contactslst WHERE userid = '" ^ user
    ^ "' AND contactid = '" ^ contact ^ "'"

  let query_contact user cont =
    unit
    ->! Caqti_type.custom
          ~encode:(fun boolean -> Ok boolean)
          ~decode:(fun boolean -> Ok boolean)
          Caqti_type.bool
    @@ "SELECT exists (SELECT 1 FROM contactslst WHERE userid = '"
    ^ user ^ "' AND contactid = '" ^ cont ^ "')"
end

let migrate () =
  let open Contacts in
  Lwt.bind (Db.exec create_contactslst ()) (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let rollback () =
  let open Contacts in
  Lwt.bind (Db.exec drop_contactslst ()) (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let insert_contact user_id contact_id fav () =
  let open Contacts in
  Lwt.bind
    (Db.exec
       (add_contact (string_of_int user_id)
          (string_of_int contact_id)
          (string_of_bool fav))
       ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let does_contact_exist user contact () =
  let open Contacts in
  Lwt.bind
    (Db.find
       (query_contact (string_of_int user) (string_of_int contact))
       ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let get_contacts_from_userid user_id () =
  let open Contacts in
  Lwt.bind
    (Db.find (get_contacts (string_of_int user_id)) ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let get_favorites user_id () =
  let open Contacts in
  Lwt.bind
    (Db.find (view_favorites (string_of_int user_id)) ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let update_make_favorite user_id contact () =
  let open Contacts in
  Lwt.bind
    (Db.exec
       (make_favorite (string_of_int user_id) (string_of_int contact))
       ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

(* Lwt.bind (Db.find (view_favorites (string_of_int user_id)) ()) (fun
   result -> match result with | Ok data2 -> Lwt.return (Ok data2) |
   Error error -> Lwt.fail (failwith (Caqti_error.show error))) | Error
   error -> Lwt.fail (failwith (Caqti_error.show error))) *)

let read_contacts_given_userid id () =
  let open Contacts in
  Lwt.bind
    (Db.fold
       (get_contacts_of_userid (string_of_int id))
       (fun { user_id; contact_id; favorite } acc ->
         { user_id; contact_id; favorite } :: acc)
       () [])
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> failwith (Caqti_error.show error))

let get_favorite user contact () =
  let open Contacts in
  Lwt.bind
    (Db.find
       (favorite_status (string_of_int user) (string_of_int contact))
       ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let update_remove_favorite user_id contact () =
  let open Contacts in
  Lwt.bind
    (Db.exec
       (remove_favorite (string_of_int user_id) (string_of_int contact))
       ())
    (fun result ->
      match result with
      | Ok data -> Lwt.return (Ok data)
      | Error error -> Lwt.fail (failwith (Caqti_error.show error)))
