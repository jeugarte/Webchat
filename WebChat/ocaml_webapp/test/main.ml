open OUnit2
open Ocaml_webapp
open User

(* Testing Plan: We automatically tested the Bot and User modules using
   OUnit testing and tested the rest of our modules through manual
   testing. We chose to implement our testing this way because the rest
   of our modules rely on PostgreSql commands which we found easier to
   test using Sql commands on Datagrip. For the functions that we tested
   with OUnit, we implemented a mixture of glass box testing and black
   box testing to test functionality as well as error or unexpected
   behavior handling. We believe that our testing approach of using
   OUnit to test purely OCaml code, DataGrip to test OCaml code that
   utilized the Caqti library, and Postman to test OCaml code that
   utilized the Opium library demonstrates the correctness of our code
   because we were able to test OCaml code, endpoints, and database
   commands each in the way we found easiest. *)

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

let response_of_bob_bot_test
    (name : string)
    (input : string)
    (rand_var : int)
    (expected_output : string) : test =
  name >:: fun _ ->
  assert_equal expected_output
    (snd (Bot.bob_bot_response input rand_var))
    ~printer:(fun s -> s)

let test_four_cases name input output1 output2 output3 output4 =
  [
    response_of_bob_bot_test
      (name ^ " case " ^ string_of_int 0)
      input 0 output1;
    response_of_bob_bot_test
      (name ^ " case " ^ string_of_int 1)
      input 1 output2;
    response_of_bob_bot_test
      (name ^ " case " ^ string_of_int 2)
      input 2 output3;
    response_of_bob_bot_test
      (name ^ " case " ^ string_of_int 3)
      input 3 output4;
  ]

let response_of_bob_bot_tests =
  test_four_cases "test yes/no question to robot" "do you know" "Yes"
    "No" "Most likely" "Maybe"
  @ test_four_cases "test yes/no question with question mark"
      "does it work?" "Yes" "No" "Most likely" "Maybe"
  @ test_four_cases "test yes/no command" "do the problem" "Umm" "Umm"
      "Umm" "Umm"
  @ test_four_cases "test wh-question" "who are you" "Huh? Why?" "What?"
      "Why?" "I dont know"
  @ test_four_cases "test one word wh-question" "what?" "Huh? Why?"
      "What?" "Why?" "I dont know"
  @ test_four_cases "test excitement" "this is so exciting!" "Nice!"
      "Cool!" "Alrighty!" "Big!"
  @ test_four_cases "test neutral punctuation" "this is boring." "Dang."
      "Hmm." "*Thinking*" "Wow!"
  @ [
      response_of_bob_bot_test "test im" "today im happy" 0
        "Hi happy. Im Bob!";
      response_of_bob_bot_test "test joke" "tell me a joke!" 1
        "How do you kiss someone at the end of the world? On the \
         apocalypse.";
    ]

let response_of_joe_bot_test
    (name : string)
    (input : string)
    (expected_output : bool * string) : test =
  name >:: fun _ ->
  assert_equal expected_output (Bot.joe_bot_response input 0)
    ~printer:(fun s -> snd s)

let response_of_joe_bot_tests =
  [
    response_of_joe_bot_test "test im" "today im happy"
      (true, "Hi happy. Im Joe!");
    response_of_joe_bot_test "test joe" "hey is joe here?"
      (true, "Hi, its Joe!");
    response_of_joe_bot_test "test sad" ":("
      (true, "Dont be sad ... Joe is here!");
    response_of_joe_bot_test "test add" "mathmode add 1 2" (true, "3");
    response_of_joe_bot_test "test multiply large"
      "mathmode multiply 178 4787" (true, "852086");
    response_of_joe_bot_test "test multiply" "mathmode multiply 2 3"
      (true, "6");
    response_of_joe_bot_test "test multiply negative"
      "mathmode multiply -1 -2" (true, "2");
    response_of_joe_bot_test "test divide" "mathmode divide 6 3"
      (true, "2");
    response_of_joe_bot_test "test divide frac" "mathmode divide 6 5"
      (true, "1");
    response_of_joe_bot_test "test subtract" "mathmode subtract 73 2"
      (true, "71");
    response_of_joe_bot_test "test subtract negative"
      "mathmode subtract 2 73" (true, "-71");
    response_of_joe_bot_test "test divide by 0" "mathmode divide 8 0"
      (true, "invalid");
    response_of_joe_bot_test "test invalid mathmode"
      "mathmode blargh 1 2" (true, "invalid");
    response_of_joe_bot_test "test invalid mathmode length"
      "mathmode plus 1 2 3" (true, "invalid");
    response_of_joe_bot_test "test invalid mathmode types"
      "mathmode sub a b" (true, "invalid");
    response_of_joe_bot_test "test invalid mathmode float"
      "mathmode add 1.3 5.7" (true, "invalid");
    response_of_joe_bot_test "test no mathmode keyword" "plus 1 + 17"
      (false, "");
    response_of_joe_bot_test "catch all" "bleh" (false, "");
  ]

let suite =
  "test suite"
  >::: List.flatten
         [
           user_tests;
           response_of_bob_bot_tests;
           response_of_joe_bot_tests;
         ]

let _ = run_test_tt_main suite
