type conversation_rec = {
  conversation_id : int;
  conversation_name : string;
  creator_id : string;
}
(**[conversation_rec] is a type record containing an int
   conversation_id- denoting the id in the convolst table-, a string
   conversation_name, and a string creator_id, representing values
   accepted in table convolst*)

val migrate : unit -> (unit, 'a) result Lwt.t
(**[migrate] creates the table convolst in postgresql if not existing
   already*)

val rollback : unit -> (unit, 'a) result Lwt.t
(**[rollback] drops the table convolst in postgresql if existing*)

val insert_convo : string -> string -> unit -> (int, 'a) result Lwt.t
(**[insert_convo] takes in a string conversation_name and string creator
   email where the database inserts these values in convolst table from
   postgresql *)

val get_convo_name_from_id : int -> unit -> (string, 'a) result Lwt.t
(**[get_convo_name_from_id] takes in an int convo_id and calls the
   database to select the id's respective conversation_name from
   convolst RI: convo_id must be an unique id existing in convolst*)

val get_creator_from_id : int -> unit -> (string, 'a) result Lwt.t
(**[get_creator_from_id] takes in an int convo_id and calls the database
   to select the id's respective creator_email from convolst RI:
   convo_id must be an unique id existing in convolst*)

val read_conversation_given_id :
  int -> unit -> (conversation_rec list, 'a) result Lwt.t
(**[get_conversation_given_id] takes in an int convo_id and calls the
   database to select the id's respective conversation_id,
   conversation_name, and creator_email from convolst. Then it returns
   it in a form of conversation_rec list. RI: convo_id must be an unique
   id existing in convolst*)
