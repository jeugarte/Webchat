open Tyxml.Html

let title = title (txt "The Whether Bee")

let home_content =
  div
    [h2
       [txt "Hello"]]

let page = 
  html 
    (head title [])
    (body [home_content])

let () =
let file = open_out "index.html" in
let fmt = Format.formatter_of_out_channel file in
Format.fprintf fmt "%a@." (pp ~indent:true ()) page;
close_out file