let rand_of_var v = if v = 4 then Random.int 4 else v

let bot_response s rand_var =
  let rec first_punc l1 =
    match l1 with
    | [] -> 1
    | h :: t -> (
        match h.[String.length h - 1] with
        | '.' -> 2
        | '!' -> 3
        | '?' -> 4
        | _ -> first_punc t)
  in
  let rec key_word l2 =
    match l2 with
    | [] -> 1
    | h :: t -> (
        match h with "joke" -> 2 | "you" -> 3 | _ -> key_word t)
  in
  let first_word l3 =
    match List.hd l3 with
    | "i'm" -> 1
    | "im" -> 1
    | "does" -> 2
    | "are" -> 2
    | "is" -> 2
    | "was" -> 2
    | "have" -> 2
    | "do" -> 2
    | "did" -> 2
    | "can" -> 2
    | "should" -> 2
    | "may" -> 2
    | "who" -> 3
    | "what" -> 3
    | "when" -> 3
    | "where" -> 3
    | "why" -> 3
    | "how" -> 3
    | "which" -> 3
    | "what's" -> 3
    | "how's" -> 3
    | "when's" -> 3
    | "who's" -> 3
    | _ -> 4
  in
  let strlist =
    List.filter
      (fun a -> a <> "")
      (String.split_on_char ' '
         (s |> String.trim |> String.lowercase_ascii))
  in
  match (first_punc strlist, key_word strlist, first_word strlist) with
  | _, _, 1 ->
      List.fold_left (fun a b -> a ^ " " ^ b) "Hi" (List.tl strlist)
      ^ ". I'm Bob!"
  | 4, _, 2 -> (
      match rand_of_var rand_var with
      | 0 -> "Yes"
      | 1 -> "No"
      | _ -> "Maybe")
  | 1, 3, 2 -> (
      match rand_of_var rand_var with
      | 0 -> "Yes"
      | 1 -> "No"
      | _ -> "Maybe")
  | _, _, 3 -> (
      match rand_of_var rand_var with
      | 0 -> "Huh? Why?"
      | 1 -> "What?"
      | 2 -> "Why?"
      | _ -> "I don't know")
  | _, 2, _ -> (
      match rand_of_var rand_var with
      | 0 ->
          "Once upon a time, there was a farmer who really liked his \
           tractors. \n\
          \  He would ride a tractor in his fields for hours at a time \
           and polish them so \n\
          \  that they were spick and span. He even had tractor \
           posters in his room! \n\
          \  However, the one thing he liked more than his tractors \
           was his wife. \n\
          \  Understandably, of course, as he was a family man. \
           Unfortunately, one day, \n\
          \  tragedy struck. His wife was killed by a tractor. The \
           farmer was devastated \n\
          \  and he could never look at his tractors in the same way \
           again. He got rid of \n\
          \  every single one of his tractors and he even ripped up \
           the tractor posters in \n\
          \  his room. However, as time past, the pain of his wife''s \
           passing slowly faded \n\
          \  away and he found himself in the dating scene again. One \
           day, he was at a \n\
          \  restaurant with his date when he heard a loud boom from \
           the kitchen. Thick black\n\
          \  plumes of smoke started filling the restaurant and panic \
           ensued as everyone \n\
          \  struggled to breath. At this point, the farmer calmly \
           stood up and said I got this! \n\
          \  as he opened his mouth and breathed in all of the smoke \
           in the building. He then\n\
          \  walked to the door and exhaled all of the smoke. When he \
           came back to his seat,\n\
          \  his date was very impressed and she asked him, How did \
           you manage to do that?\n\
          \  The farmer responded, Oh, it''s because I''m an \
           ex-tractor fan."
      | 1 ->
          "How do you kiss someone at the end of the world? On the \
           apocalypse."
      | 2 ->
          "Once upon a time, there was a couple -- a man named Pablo \
           and his wife Michelle. \n\
          \  One day, one of Pablo''s good friends invited him to a \
           Halloween costume party. \n\
          \  Pablo was very excited and agree to go, but he had one \
           problem ... he didn''t \n\
          \  have a costume yet. So, as the date of the party drew \
           closer and closer, Pablo \n\
          \  visited Party City and many other stores to find the \
           perfect costume. But, he\n\
          \  couldn''t find a costume that met his expectations. \
           Indeed, he wanted a matching\n\
          \  costume with his wife. Finally, Pablo woke up on the day \
           of the party realizing\n\
          \  that he still didn''t have a proper costume. Luckily, \
           right before the party was \n\
          \  supposed to start, Pablo came up with a brilliant idea \
           for a costume. And so, he\n\
          \  went to the party very proud of himself. When he showed \
           up to the party, his friend\n\
          \  looked him up and down and asked, \"Hey Pablo, what''re \
           you supposed to be?\" \"Oh,\" \n\
          \  said Pablo \"I''m a turtle.\" \"So what''s your wife \
           doing on your back?\" asked his \n\
          \  friend quizzically. To which, Pablo responded, \"Oh, \
           that''s Michelle.\""
      | _ ->
          "What''s the difference between a steak and a meteorite? A \
           steak is pretty\n\
          \  meaty but the other is a little meteor.")
  | 3, _, _ -> (
      match rand_of_var rand_var with
      | 0 -> "Nice!"
      | 1 -> "Cool!"
      | 2 -> "Alrighty."
      | _ -> "Big!")
  | 2, _, _ -> (
      match rand_of_var rand_var with
      | 0 -> "Dang."
      | 1 -> "Hmm."
      | 2 -> "*Thinking*"
      | _ -> "Wow!")
  | _, _, _ -> "Umm"