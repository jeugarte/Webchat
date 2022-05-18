type users_conversation = {
  conversation_id : int;
  user_id : int;
}

type get_user = {
  email : string;
  username : string;
}

type conversation_id = { id : int }

val convo_of_yojson : Yojson.Safe.t -> conversation_id
val migrate : unit -> (unit, 'a) result Lwt.t
val rollback : unit -> (unit, 'a) result Lwt.t

val insert_user_conversation :
  int -> int -> unit -> (unit, 'a) result Lwt.t

val get_conversationid_from_userid :
  int -> unit -> (string, 'a) result Lwt.t

val get_users_from_conversationid :
  int -> unit -> (string list, 'a) result Lwt.t

val read_conversations_given_user :
  int -> unit -> (users_conversation list, 'a) result Lwt.t
