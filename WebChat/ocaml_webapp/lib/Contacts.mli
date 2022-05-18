type contact = {
  user_contact_id : int;
  user_id : int;
  contact_id : int;
  favorite : bool;
}
(**[contact] is a type record containing an int user_contact_id-
   denoting the id in the table-, an int user_id, an int contact_id, and
   a boolean favorite denoting if the user is a favorite of the contact*)

type get_contact = {
  user_id : int;
  contact_id : int;
  favorite : bool;
}
(**[get_contact] is a type record similar to type [contact], just
   without an int denotd the id in contactslst*)

val migrate : unit -> (unit, 'a) result Lwt.t
(**[migrate] creates the table contactslst in postgresql if not existing
   already*)

val rollback : unit -> (unit, 'a) result Lwt.t
(**[rollback] drops the table contactslst in postgresql if existing*)

val insert_contact :
  int -> int -> bool -> unit -> (unit, 'a) result Lwt.t
(**[insert_contact] takes in a int user_id, int contact_id, and boolean
   favorite where the database inserts these values in contactslst table
   from postgresql RI: user_id and contact_id are valid ids, given from
   usrlst and contactslst tables respectively*)

val get_contacts_from_userid : int -> unit -> (string, 'a) result Lwt.t
(**[get_contacts_from_userid] takes in an int user_id and calls the
   database to select one contact from contactslst given that contact
   with user_id RI: user_id is a valid id, given from usrlst table*)

val get_favorites : int -> unit -> (string, 'a) result Lwt.t
(**[get_favorites] takes in an int user_id and calls the database to
   select all contacts from contactslst such that they are favorites
   with user_id RI: user_id is a valid id, given from usrlst table *)

val update_make_favorite : int -> int -> unit -> (unit, 'a) result Lwt.t
(**[update_make_favorite] takes in an int user_id as well as contact_id
   and calls the database to update their contact from contactslst such
   that they are now favorites RI: user_id is a valid id, given from
   usrlst table; favorite from contactslst must be false *)

val update_remove_favorite :
  int -> int -> unit -> (unit, 'a) result Lwt.t
(**[update_remove_favorite] takes in an int user_id as well as
   contact_id and calls the database to update their contact from
   contactslst such that they are no longer favorites RI: user_id an
   contact_id are valid ids, given from usrlst and contactslst table
   favorite from contactslst must be true*)

val read_contacts_given_userid :
  int -> unit -> (get_contact list, 'a) result Lwt.t
(**[get_contacts_from_userid] takes in an int user_id and calls the
   database to select ALL contacts from contactslst given that they are
   contacts with user_id RI: user_id is a valid id, given from usrlst
   table*)

val does_contact_exist : int -> int -> unit -> (bool, 'a) result Lwt.t
(**[does_contact_exist] takes in an int user_id and calls the database
   to return a boolean whether there exists a user_id with a contact
   contact_id from contactslst RI: user_id an contact_id are valid ids,
   given from usrlst and contactslst table *)

val get_favorite : int -> int -> unit -> (bool, 'a) result Lwt.t
(**[update_make_favorite] takes in an int user_id as well as contact_id
   and calls the database to select if contact_id is a favorite of
   user_id form contactslst RI: user_id is a valid id, given from usrlst
   table; There must exist a user_id and contact_id contact *)
