type message = {username : string; msg : string}

val yojson_of_message : message -> Yojson.Safe.t

val message_of_yojson : Yojson.Safe.t -> message