type message = {
  userid: string;
  msg: string
}

val migrate : unit -> (unit, 'a) result Lwt.t

val read_msgs : unit -> message list Lwt.t

val add_msg : message -> unit Lwt.t