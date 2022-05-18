type message = {
  senderid : int;
  convoid : int;
  msg : string;
}
(**[message] is a type record containing an int senderid- denoting the
   id in the usrlst table-, an int convoid- denoting the id in the
   convolst table-, and string msg. This record represents the value
   accepted in table userconvolst*)

type message_str = {
  senderemail : string;
  convoid : int;
  msg : string;
}
(**[message_str] is a type record containing an string senderemail-
   denoting the email in the usrlst table-, an int convoid - denoting
   the id in the convolst table-, and string msg. This record represents
   the value needed for Yojson*)

val message_of_yojson : Yojson.Safe.t -> message_str
(** [message_of_yojson] takes in a Yojson.Safe.t, which has fields
    "sender_email", "conversation_id", and "message", and is converted
    into a type message_str *)

val migrate : unit -> (unit, 'a) result Lwt.t
(**[migrate] creates the table msglst in postgresql if not existing
   already*)

val rollback : unit -> (unit, 'a) result Lwt.t
(**[rollback] drops the table msglst in postgresql if existing*)

val add_msg : int -> int -> string -> unit -> (unit, 'a) result Lwt.t
(**[add_msg] takes in a int senderid, int convoid, and string msg where
   the database inserts these values in msglst table from postgresql.
   Returns Lwt.t unit. RI: senderid is a unique and existing primary key
   in usrlst and convoid is a unique and existing primary key in
   convolst*)

val read_sent_msgs : string -> unit -> (unit, 'a) result Lwt.t
(**[read_sent_msgs] takes in a string of int of a sender_id, which
   signals the databse to return all msgs sent out by that user, which
   is then compiled in a list. Unit is returned. This defintion is
   depricated RI: sender_id is a valid and unique primary key from
   usrlst*)

val read_conversation_msgs :
  int -> unit -> (message list, 'a) result Lwt.t
(** [read_conversation_msgs] takes in an int conversation_id. The
    database is then executed to select all senderid, convoids, and msgs
    such that have convoid. Then these outputs are stored in a type
    message and then returned as a list of all messages. RI: convoid
    must be an existing and unique primary key from convolst*)

val read_all : unit -> (message list, 'a) result Lwt.t
(** [read_conversation_msgs] signals the database to select all
    senderid, convoids, and msgs that exist in msglst. Then these
    outputs are stored in a type message and then returned as a list of
    all messages.*)
