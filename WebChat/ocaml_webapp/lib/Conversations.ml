open Lwt.Infix


module Db : Caqti_lwt.CONNECTION = 
(val Caqti_lwt.connect (Uri.of_string "postgresql://localhost:5432") >>= Caqti_lwt.or_fail |> Lwt_main.run)

open Caqti_request.Infix
open Caqti_type.Std

type conversation = {
  conversation_id : int;
  conversation_name : int;
  creator_id : int
}

module Conversations = struct
  let create_convolst = unit ->. unit @@ 
    {eos|
      CREATE TABLE IF NOT EXISTS convolst (
        id SERIAL PRIMARY KEY,
        convo_name TEXT NOT NULL,
        creator_id TEXT NOT NULL
      )
    |eos}

  let drop_convolst = unit ->. unit @@
    "DROP TABLE convolst"
  
  let add_convo cname creator = unit ->. unit @@ 
    "INSERT INTO convolst (convo_name, creator) VALUES (cname, creator)"

  let get_convo_name gc_id = unit ->! (Caqti_type.custom ~encode:(fun s -> Ok s) 
  ~decode:(fun s -> Ok s) Caqti_type.string) @@
    "SELECT convo_name FROM convolst WHERE id = gc_id"

  let get_creator gc_id = unit ->! (Caqti_type.custom ~encode:(fun s -> Ok s) 
  ~decode:(fun s -> Ok s) Caqti_type.string) @@
    "SELECT creator FROM convolst WHERE id = gc_id"

end


let migrate () = let open Conversations in
   Lwt.bind (Db.exec create_convolst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let rollback () = let open Conversations in
    Lwt.bind (Db.exec drop_convolst ()) (fun result ->
match result with
| Ok data -> Lwt.return (Ok data)
| Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let insert_convo cname creator () = let open Conversations in
  Lwt.bind (Db.exec (add_convo cname creator) ()) (fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let get_convo_name_from_id id () = let open Conversations in 
  Lwt.bind (Db.find (get_convo_name id) ())(fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))

let get_creator_from_id id () = let open Conversations in 
  Lwt.bind (Db.find (get_creator id) ())(fun result ->
    match result with
    | Ok data -> Lwt.return (Ok data)
    | Error error -> Lwt.fail (failwith (Caqti_error.show error)))