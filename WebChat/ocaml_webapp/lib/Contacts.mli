type contact = {
  user_contact_id : int;
  user_id : int;
  contact_id : int;
  favorite : bool
}

val migrate : unit -> (unit, 'a) result Lwt.t

val rollback : unit -> (unit, 'a) result Lwt.t

val insert_contact : int -> int -> bool -> unit -> (unit, 'a) result Lwt.t

val get_contacts_from_userid :  int -> unit -> (string, 'a) result Lwt.t

val get_favorites :  int -> unit -> (string, 'a) result Lwt.t

val update_make_favorite : int -> int -> unit -> (string, 'a) result Lwt.t

val update_remove_favorite : int -> int -> unit -> (string, 'a) result Lwt.t