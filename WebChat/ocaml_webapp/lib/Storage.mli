type message = {
  senderid : string;
  convoid : string;
  msg : string;
}

val migrate : unit -> (unit, 'a) result Lwt.t
val rollback : unit -> (unit, 'a) result Lwt.t

val add_msg :
  string -> string -> string -> unit -> (unit, 'a) result Lwt.t

val read_sent_msgs : string -> unit -> (unit, 'a) result Lwt.t
val read_recieved_msgs : string -> unit -> (unit, 'a) result Lwt.t
val read_all : unit -> (message list, 'a) result Lwt.t