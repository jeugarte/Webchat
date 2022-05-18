type user = {
  email : string;
  password : string;
  username : string;
}
(**[user] is a type record containing a string email- denoting the email
   in the table-, a string username, and a string psswword ,
   representing values accepted in table usrlst*)

type get_user = {
  email : string;
  username : string;
}
(**[get_user] is a type record similar to [user], except without the
   user's password*)

type get_contact_both = {
  user_email : string;
  contact_email : string;
}
(** [get_contact_both] is a type record similar to [get_user], but
    instead denotes two users and both of their emails*)

type get_userconvo = { email : string }
(** [get_userconvo] is a type record similar to [get_user], but instead
    denotes only the user's email*)

val yojson_of_user : user -> Yojson.Safe.t
(** [yojson_of_user] takes in a type user and outputs the Yojson.Safe.t
    version of it *)

(* [user_of_yojson] takes in a Yojson.Safe.t, which has fields "email",
   "password", and "username", and is converted into a type user *)
val user_of_yojson : Yojson.Safe.t -> user

val usercontact_of_yojson : Yojson.Safe.t -> get_userconvo
(** [usercontact_of_yojson] takes in a Yojson.Safe.t, which has a field
    "email", and is converted into a type get_userconvo*)

val both_of_yojson : Yojson.Safe.t -> get_contact_both
(** [both_of_yojson] takes in a Yojson.Safe.t, which has fields
    "user_email" and "contact_email", and is converted into a type
    get_userconvo*)

val migrate : unit -> (unit, 'a) result Lwt.t
(**[migrate] creates the table usrlst in postgresql if not existing
   already*)

val rollback : unit -> (unit, 'a) result Lwt.t
(**[rollback] drops the table usrlst in postgresql if existing*)

val add_usr :
  string -> string -> string -> unit -> (unit, 'a) result Lwt.t
(**[add_usr] takes in a string email, string password, and string
   username where the database inserts these values in usrlst table from
   postgresql *)

val email_exists : string -> unit -> (bool, 'a) result Lwt.t
(**[email_exists] takes in a string email and calls the database to
   return a boolean whether there exists a user with the email from
   usrlst *)

val username_exists : string -> unit -> (bool, 'a) result Lwt.t
(**[email_exists] takes in a string username and calls the database to
   return a boolean whether there exists a user with the username from
   usrlst *)

val user_of_email : string -> unit -> (string, 'a) result Lwt.t
(** [user_of_email] takes in a string email, executing the database to
    find a user with the specfic email and then returning their username
    from usrlst RI: email MUST be somewhere in the table*)

val change_username :
  string -> string -> unit -> (unit, 'a) result Lwt.t
(** [change_username] takes in a string email and string username, in
    which the databases updates the current username of the given email
    with the new username given. Returns Lwt.t unit. RI: email is an
    existing and unique email in usrlst*)

val email_of_user : string -> unit -> (string, 'a) result Lwt.t
(** [email_of_user] takes in a string username, executing the database
    to find a user with the specfic username and then returning their
    email from usrlst RI: username MUST be somewhere in the table*)

val check_password :
  string -> string -> string -> unit -> (bool, 'a) result Lwt.t
(** [check_password] takes in a string email, string password, and
    string username where the database finds if any user with the valid
    given username or email matches the given password. This allows
    login and authentication to their user account RI: email and
    username must be somewhere in usrlst*)

val read_all_given_id : int -> unit -> (get_user list, 'a) result Lwt.t
(**[read_all_given_id] takes in an int user_id and calls the database to
   select the id's respective username and email from usrlst RI: user_id
   must be an unique id existing in usrlst*)

val id_from_email : string -> unit -> (int, 'a) result Lwt.t
(** [id_of_email] takes in a string email, executing the database to
    find a user with the unique email and then returning their unqiue id
    from usrlst RI: email MUST be somewhere in the table*)
