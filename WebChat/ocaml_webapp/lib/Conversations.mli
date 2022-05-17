type conversation = {
  conversation_id : int;
  conversation_name : int;
  creator_id : int
}

val migrate : unit -> (unit, 'a) result Lwt.t

val rollback : unit -> (unit, 'a) result Lwt.t

val insert_convo : string -> string -> unit -> (unit, 'a) result Lwt.t

val get_convo_name_from_id :  int -> unit -> (string, 'a) result Lwt.t

val get_creator_from_id :  int -> unit -> (string, 'a) result Lwt.t

(* val read_all : unit -> (conversation list, 'a) result Lwt.t *)