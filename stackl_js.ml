open Js_of_ocaml
open Js_of_ocaml_lwt
open Lwt.Infix
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html
open Graphics_js

let canvas = ref None
let input = ref None
let output = ref None

let set_text_area_content text =
  match !input with None -> () | Some input -> input##.value := Js.string text

let fetch_file filename =
  XmlHttpRequest.get filename >>= fun r ->
  if r.XmlHttpRequest.code = 200 then Lwt.return r.XmlHttpRequest.content
  else Lwt.fail_with "Failed to load file"

let load_text filename =
  fetch_file filename >>= fun text -> Lwt.return (set_text_area_content text)

let samples_files_lst =
  [
    "canvas.sl";
    "factorial.sl";
    "fib.sl";
    "koch.sl";
    "mandel_canvas.sl";
    "tokucha.sl";
  ]

let process event =
  let data = Js.Unsafe.coerce event##.data in
  let convert_coords coords =
    coords |> Js.to_array |> Array.map (fun obj -> (obj##.x, obj##.y))
  in
  match data##.funname with
  | "clear_graph" -> clear_graph ()
  | "moveto" -> moveto data##.x data##.y
  | "lineto" -> lineto data##.x data##.y
  | "set_color" -> set_color data##.color
  | "fill_poly" -> fill_poly (convert_coords data##.coords)
  | "output" -> (
      match !output with
      | None -> ()
      | Some output -> output##.value := data##.output)
  | _ -> raise Not_found

let onload _ =
  let worker = Worker.create "_build/default/worker_js.bc.js" in
  let document = Html.window##.document in
  let samples = Html.getElementById "samples" in
  let btn = Html.getElementById "process" in
  let () =
    (input :=
       match Html.getElementById_coerce "input" Html.CoerceTo.textarea with
       | None -> raise Not_found
       | Some input -> Some input);
    (canvas :=
       match Html.getElementById_coerce "canvas" Html.CoerceTo.canvas with
       | None -> raise Not_found
       | Some canvas ->
           open_canvas canvas;
           Some canvas);
    (output :=
       match Html.getElementById_coerce "output" Html.CoerceTo.textarea with
       | None -> raise Not_found
       | Some output -> Some output);
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
          let input =
            match !input with
            | None -> Js.string ""
            | Some input -> input##.value
          in
          worker##.onmessage :=
            Dom.handler (fun event ->
                process event;
                Js._false);
          let msg =
            object%js
              val input = input
            end
          in
          worker##postMessage msg;
          Js._false)
  in
  Js._false

let () = Html.window##.onload := Html.handler onload
