open Js_of_ocaml
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html

let canvas = ref None

module G = struct
  include Graphics_js

  let open_graph_area () =
    match !canvas with
    | None -> raise Not_found
    | Some canvas -> open_canvas canvas
end

module Eval = Eval.MakeEval (G)

let process input output =
  let () = Eval.reset () in
  let input = Js.to_string input##.value in
  let tree = Parser.parse input in
  let _ = Eval.eval_list 0 tree Vm.empty in
  output##.value := Js.string (Eval.get_output_string ())

let onload _ =
  let input =
    match Html.getElementById_coerce "input" Html.CoerceTo.textarea with
    | None -> raise Not_found
    | Some input -> input
  in
  let btn = Html.getElementById "process" in
  let output =
    match Html.getElementById_coerce "output" Html.CoerceTo.textarea with
    | None -> raise Not_found
    | Some output -> output
  in
  let () =
    (canvas :=
       match Html.getElementById_coerce "canvas" Html.CoerceTo.canvas with
       | None -> raise Not_found
       | Some canvas -> Some canvas);
    btn##.onclick :=
      Html.handler (fun _ ->
          process input output;
          Js._false)
  in
  Js._false

let () = Html.window##.onload := Html.handler onload
