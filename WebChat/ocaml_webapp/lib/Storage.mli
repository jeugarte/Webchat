type message = {
  senderid : int;
  recipientid : int;
  msg : string
}

val migrate : unit -> (unit, 'a) result Lwt.t

val add_msg : string -> string -> string -> unit -> (unit, 'a) result Lwt.t

val read_sent_msgs :  string -> unit -> (unit, 'a) result Lwt.t

val read_recieved_msgs :  string -> unit -> (unit, 'a) result Lwt.t

val read_all : unit -> (unit, 'a) result Lwt.t