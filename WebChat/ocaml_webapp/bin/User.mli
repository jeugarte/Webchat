type user =
    { email: string
    ; password : string;
    username: string
    }
  
val yojson_of_user : user -> Yojson.Safe.t

val user_of_yojson : Yojson.Safe.t -> user