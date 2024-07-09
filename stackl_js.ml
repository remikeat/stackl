open Js_of_ocaml
open Js_of_ocaml_lwt
open Lwt.Infix
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html

let canvas = ref None
let input = ref None

module G = struct
  include Graphics_js

  let open_graph_area () =
    match !canvas with
    | None -> raise Not_found
    | Some canvas -> open_canvas canvas
end

module Eval = Eval.MakeEval (G)

let set_text_area_content text =
  match !input with None -> () | Some input -> input##.value := Js.string text

let fetch_file filename =
  XmlHttpRequest.get filename >>= fun r ->
  if r.XmlHttpRequest.code = 200 then Lwt.return r.XmlHttpRequest.content
  else Lwt.fail_with "Failed to load file"

let load_text filename =
  fetch_file filename >>= fun text -> Lwt.return (set_text_area_content text)

let process input output =
  let () = Eval.reset () in
  let input =
    match input with None -> "" | Some input -> Js.to_string input##.value
  in
  let tree = Parser.parse input in
  let _ = Eval.eval_list 0 tree Vm.empty in
  output##.value := Js.string (Eval.get_output_string ())

let samples_files_lst =
  [
    "canvas.sl";
    "factorial.sl";
    "fib.sl";
    "koch.sl";
    "mandel_canvas.sl";
    "tokucha.sl";
  ]

let onload _ =
  let document = Html.window##.document in
  let samples = Html.getElementById "samples" in
  let btn = Html.getElementById "process" in
  let output =
    match Html.getElementById_coerce "output" Html.CoerceTo.textarea with
    | None -> raise Not_found
    | Some output -> output
  in
  let () =
    (input :=
       match Html.getElementById_coerce "input" Html.CoerceTo.textarea with
       | None -> raise Not_found
       | Some input -> Some input);
    (canvas :=
       match Html.getElementById_coerce "canvas" Html.CoerceTo.canvas with
       | None -> raise Not_found
       | Some canvas -> Some canvas);
    samples_files_lst
    |> List.fold_left
         (fun () file ->
           let button = Html.createButton document in
           button##.innerText := Js.string file;
           button##.onclick :=
             Html.handler (fun _ ->
                 let _ = load_text ("scripts/" ^ file) in
                 Js._false);
           Dom.appendChild samples button)
         ();
    btn##.onclick :=
      Html.handler (fun _ ->
          process !input output;
          Js._false)
  in
  Js._false

let () = Html.window##.onload := Html.handler onload
