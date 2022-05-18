type message = {
  senderid : int;
  convoid : int;
  msg : string;
}

type message_str = {
  senderemail : string;
  convoid : int;
  msg : string;
}

val message_of_yojson : Yojson.Safe.t -> message_str
val migrate : unit -> (unit, 'a) result Lwt.t
val rollback : unit -> (unit, 'a) result Lwt.t
val add_msg : int -> int -> string -> unit -> (unit, 'a) result Lwt.t
val read_sent_msgs : string -> unit -> (unit, 'a) result Lwt.t

val read_conversation_msgs :
  int -> unit -> (message list, 'a) result Lwt.t

val read_all : unit -> (message list, 'a) result Lwt.t