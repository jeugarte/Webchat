open Opium
open OUnit2
open User

let yojson_of_string yojson =
  match yojson with
  | `Assoc [ ("email", `String email); ("password", `String password); 
  ("username", `String username) ] 
  -> email ^ " " ^ password ^ " " ^ username
  | _ -> failwith "invalid user json"

let yojson_of_user_test
    (name : string)
    (u : User.user)
    (expected_output : Yojson.Safe.t) : test =
  name >:: fun _ ->
  assert_equal expected_output (User.yojson_of_user u) ~printer: yojson_of_string