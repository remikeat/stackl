open Drawer
open Eval
open Js_of_ocaml
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html

let process input output =
  let input = Js.to_string input##.value in
  let () = clear_output_string () in
  let tree = Parser.parse input in
  let _ = eval_list 0 tree Vm.empty in
  let () = if !drawer.window_opened then interactive () in
  output##.innerText := Js.string (get_output_string ())

let onload _ =
  let input =
    match Html.getElementById_coerce "input" Html.CoerceTo.textarea with
    | None -> raise Not_found
    | Some input -> input
  in
  let btn = Html.getElementById "process" in
  let output = Html.getElementById "output" in
  let () =
    btn##.onclick :=
      Html.handler (fun _ ->
          process input output;
          Js._false)
  in
  Js._false

let () = Html.window##.onload := Html.handler onload
