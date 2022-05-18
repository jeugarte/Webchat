val bob_bot_response : string -> int -> bool * string
(** [bob_bot_response] takes in a string [s] and an int [i] and returns
    a tuple [(b,response)] where [b] is a boolean representing if
    bob-bot will respond and [response] is the string representing the
    response to the input string [s]. [i] is a int used purely for
    testing randomness and is [0] to allow random behavior. **)

val joe_bot_response : string -> int -> bool * string
(** [joe_bot_response] takes in a string [s] and an int [i] and returns
    a tuple [(b,response)] where [b] is a boolean representing if
    joe-bot will respond and [response] is the string representing the
    response to the input string [s]. [i] is a int included to match bot
    response signatures **)
