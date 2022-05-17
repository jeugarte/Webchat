type conversation_rec = {
  conversation_id : int;
  conversation_name : string;
  creator_id : string;
}

val migrate : unit -> (unit, 'a) result Lwt.t
val rollback : unit -> (unit, 'a) result Lwt.t
val insert_convo : string -> string -> unit -> (unit, 'a) result Lwt.t
val get_convo_name_from_id : int -> unit -> (string, 'a) result Lwt.t
val get_creator_from_id : int -> unit -> (string, 'a) result Lwt.t

val read_conversation_given_id :
  int -> unit -> (conversation_rec list, 'a) result Lwt.t

(*val read_all : unit -> (conversation list, 'a) result Lwt.t*)