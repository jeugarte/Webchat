open OUnit2
open Ocaml_webapp
open User

let string_of_yojson yojson =
  match yojson with
  | `Assoc
      [
        ("email", `String email);
        ("password", `String password);
        ("username", `String username);
      ] ->
      email ^ " " ^ password ^ " " ^ username
  | _ -> failwith "invalid user json"

let string_of_user u =
  match u with
  | { email; password; username } ->
      email ^ " " ^ password ^ " " ^ username

let yojson_of_user_test
    (name : string)
    (u : User.user)
    (expected_output : Yojson.Safe.t) : test =
  name >:: fun _ ->
  assert_equal expected_output (User.yojson_of_user u)
    ~printer:string_of_yojson

let user_of_yojson_test
    (name : string)
    (json : Yojson.Safe.t)
    (expected_output : User.user) : test =
  name >:: fun _ ->
  assert_equal expected_output
    (User.user_of_yojson json)
    ~printer:string_of_user

let user_tests =
  [
    user_of_yojson_test
      "utoy, Email = a@gmail.com, Password = a, Username = aa"
      ("ocaml_webapp/bin/atest.json" |> Yojson.Safe.from_file)
      { email = "a@gmail.com"; password = "a"; username = "aa" };
    yojson_of_user_test
      "ytou, Email = a@gmail.com, Password = a, Username = aa"
      { email = "a@gmail.com"; password = "a"; username = "aa" }
      ("ocaml_webapp/bin/atest.json" |> Yojson.Safe.from_file);
  ]

let response_of_bot_test
    (name : string)
    (input : string)
    (rand_var : int)
    (expected_output : string) : test =
  name >:: fun _ ->
  assert_equal expected_output (Bot.bot_response input rand_var)
    ~printer:(fun s -> s)

let test_four_cases name input output1 output2 output3 output4 =
  [
    response_of_bot_test
      (name ^ " case " ^ string_of_int 0)
      input 0 output1;
    response_of_bot_test
      (name ^ " case " ^ string_of_int 1)
      input 1 output2;
    response_of_bot_test
      (name ^ " case " ^ string_of_int 2)
      input 2 output3;
    response_of_bot_test
      (name ^ " case " ^ string_of_int 3)
      input 3 output4;
  ]

let response_of_bot_tests =
  test_four_cases "test yes/no question to robot" "do you know" "Yes"
    "No" "Most likely" "Maybe"
  @ test_four_cases "test yes/no question with question mark"
      "does it work?" "Yes" "No" "Most likely" "Maybe"
  @ test_four_cases "test yes/no command" "do the problem" "Umm" "Umm"
      "Umm" "Umm"
  @ test_four_cases "test wh-question" "who are you" "Huh? Why?" "What?"
      "Why?" "I don't know"
  @ test_four_cases "test one word wh-question" "what?" "Huh? Why?"
      "What?" "Why?" "I don't know"
  @ test_four_cases "test excitement" "this is so exciting!" "Nice!"
      "Cool!" "Alrighty!" "Big!"
  @ test_four_cases "test neutral punctuation" "this is boring." "Dang."
      "Hmm." "*Thinking*" "Wow!"
  @ [
      response_of_bot_test "test im" "today im happy" 0
        "Hi happy. I'm Bob!";
      response_of_bot_test "test joke" "tell me a joke!" 1
        "How do you kiss someone at the end of the world? On the \
         apocalypse.";
    ]

let suite =
  "test suite" >::: List.flatten [ user_tests; response_of_bot_tests ]

let _ = run_test_tt_main suite
