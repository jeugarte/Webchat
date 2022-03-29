type message = {
  userid: string;
  msg: string
}

val migrate : unit -> (unit, 'a) result Lwt.t

val add_msg : string -> string -> unit -> (unit, 'a) result Lwt.t

val read_msgs :  string -> unit -> (unit, 'a) result Lwt.t

val read_all : unit -> (unit, 'a) result Lwt.t