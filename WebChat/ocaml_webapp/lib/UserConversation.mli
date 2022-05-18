type users_conversation = {
  conversation_id : int;
  user_id : int;
}
(**[users_conversation] is a type record containing an int
   conversation_id- denoting the id in the convolst table- and an int
   user_id - denoting the id in the usrlst table-, representing value
   accepted in table userconvolst*)

type get_user = {
  email : string;
  username : string;
}
(**[get_user] is a type record similar to [user] in the User module,
   except without the user's password*)

type conversation_id = { id : int }
(** [conversation_id] is a type record with an int id denoting the the
    id in the convolst*)

val convo_of_yojson : Yojson.Safe.t -> conversation_id
(** [convo_of_yojson] takes in a Yojson.Safe.t, which has a field "id",
    and is converted into a type conversation_id*)

val migrate : unit -> (unit, 'a) result Lwt.t
(**[migrate] creates the table userconvolst in postgresql if not
   existing already*)

val rollback : unit -> (unit, 'a) result Lwt.t
(**[rollback] drops the table userconvolst in postgresql if existing*)

val insert_user_conversation :
  int -> int -> unit -> (unit, 'a) result Lwt.t
(**[add_usr] takes in an int conversation_id and int user_id where the
   database inserts these values in userconvolst table from postgresql.
   Returns Lwt.t unit RI: conversation_id and user_id are valid and
   unique ids instanstiated from convolst and usrlst respectively*)

val get_conversationid_from_userid :
  int -> unit -> (string, 'a) result Lwt.t
(**[get_conversationid_from_userid] takes in an int user_id and calls
   the database to select the id's respective conversation_id from
   userconvolst. RI: user_id must be an unique id existing in usrlst*)

val get_users_from_conversationid :
  int -> unit -> (string list, 'a) result Lwt.t
(**[get_users_from_conversationid] takes in an int conversation_id and
   calls the database to select all the id's respective user_id's
   whenever the parameter shows up in the table userconvolst. Then, it
   selects all the emails from the chosen ids from usrlst. Returns a
   list of emails from all the users. RI: conversation_id must be an
   unique id existing in convolst*)

val read_conversations_given_user :
  int -> unit -> (users_conversation list, 'a) result Lwt.t
(**[read_conversations_given_user] takes in an int user_id and calls the
   database to select ALL the id's respective conversation_id from
   userconvolst. Whenever the user_id appears in userconvolst, it
   compiles and returns a list, which is type users_conversation. RI:
   user_id must be an unique id existing in usrlst*)
