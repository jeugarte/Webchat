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