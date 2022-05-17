type users_conversation = {
  conversation_id : int;
  user_id : int;
}

val migrate : unit -> (unit, 'a) result Lwt.t
val rollback : unit -> (unit, 'a) result Lwt.t

val insert_user_conversation :
  int -> int -> unit -> (unit, 'a) result Lwt.t

val get_conversationid_from_userid :
  int -> unit -> (string, 'a) result Lwt.t

val get_userid_from_conversationid :
  int -> unit -> (string, 'a) result Lwt.t

val read_conversations_given_user :
  int -> unit -> (users_conversation list, 'a) result Lwt.t
(* val update_make_favorite : int -> int -> unit -> (string, 'a) result
   Lwt.t

   val update_remove_favorite : int -> int -> unit -> (string, 'a)
   result Lwt.t*)
