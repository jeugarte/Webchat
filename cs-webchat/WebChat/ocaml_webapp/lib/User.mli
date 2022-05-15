(* user type *)
type user =
    { email: string
    ; password : string;
    username: string
    }

(* yojson_of_user converts a user type to a json *)
val yojson_of_user : user -> Yojson.Safe.t

(* user_of_yojson converts a json to a user type *)
val user_of_yojson : Yojson.Safe.t -> user

val migrate : unit -> (unit, 'a) result Lwt.t

val rollback : unit -> (unit, 'a) result Lwt.t

val add_usr : string -> string -> string -> unit -> (unit, 'a) result Lwt.t

val email_exists : string -> unit -> (bool, 'a) result Lwt.t

val username_exists : string -> unit -> (bool, 'a) result Lwt.t

val user_of_email : string -> unit -> (string, 'a) result Lwt.t

val email_of_user : string -> unit -> (string, 'a) result Lwt.t

val check_password : string -> string -> string -> unit -> (bool, 'a) result Lwt.t