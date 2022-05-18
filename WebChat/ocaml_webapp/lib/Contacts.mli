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

val migrate : unit -> (unit, 'a) result Lwt.t
val rollback : unit -> (unit, 'a) result Lwt.t

val insert_contact :
  int -> int -> bool -> unit -> (unit, 'a) result Lwt.t

val get_contacts_from_userid : int -> unit -> (string, 'a) result Lwt.t
val get_favorites : int -> unit -> (string, 'a) result Lwt.t
val update_make_favorite : int -> int -> unit -> (unit, 'a) result Lwt.t

val update_remove_favorite :
  int -> int -> unit -> (unit, 'a) result Lwt.t

val read_contacts_given_userid :
  int -> unit -> (get_contact list, 'a) result Lwt.t

val does_contact_exist : int -> int -> unit -> (bool, 'a) result Lwt.t
val get_favorite : int -> int -> unit -> (bool, 'a) result Lwt.t
