open OUnit2
open Ocaml_webapp
open User

let string_of_yojson yojson =
  match yojson with
  | `Assoc [ ("email", `String email); ("password", `String password); 
  ("username", `String username) ] 
  -> email ^ " " ^ password ^ " " ^ username
  | _ -> failwith "invalid user json"

let string_of_user u =
  match u with
  | {email;password;username} -> email ^ " " ^ password ^ " " ^ username

let yojson_of_user_test
    (name : string)
    (u : User.user)
    (expected_output : Yojson.Safe.t) : test =
  name >:: fun _ ->
  assert_equal expected_output (User.yojson_of_user u) ~printer: string_of_yojson

let user_of_yojson_test
    (name : string)
    (json : Yojson.Safe.t)
    (expected_output : User.user) : test =
  name >:: fun _ ->
  assert_equal expected_output (User.user_of_yojson json) ~printer: string_of_user

let user_tests = [
    user_of_yojson_test "utoy, Email = a@gmail.com, Password = a, Username = aa" 
    ("ocaml_webapp/bin/atest.json" |> Yojson.Safe.from_file)
    ({email = "a@gmail.com"; password = "a"; username = "aa"});
    yojson_of_user_test "ytou, Email = a@gmail.com, Password = a, Username = aa"
    ({email = "a@gmail.com"; password = "a"; username = "aa"})
    ("ocaml_webapp/bin/atest.json" |> Yojson.Safe.from_file)
]

let suite =
  "test suite"
  >::: List.flatten [ user_tests ]

let _ = run_test_tt_main suite

