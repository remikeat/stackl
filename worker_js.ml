open Js_of_ocaml
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html

module G = struct
  type color = Graphics_js.color

  let open_graph_area () = ()

  let moveto x y =
    let msg =
      object%js
        val funname = Js.string "moveto"
        val x = x
        val y = y
      end
    in
    Worker.post_message msg

  let lineto x y =
    let msg =
      object%js
        val funname = Js.string "lineto"
        val x = x
        val y = y
      end
    in
    Worker.post_message msg

  let set_color color =
    let msg =
      object%js
        val funname = Js.string "set_color"
        val color = color
      end
    in
    Worker.post_message msg

  let fill_poly coords =
    let js_coords =
      coords
      |> Array.map (fun (x, y) ->
             object%js
               val x = x
               val y = y
             end)
      |> Js.array
    in
    let msg =
      object%js
        val funname = Js.string "fill_poly"
        val coords = js_coords
      end
    in
    Worker.post_message msg

  let rgb = Graphics_js.rgb

  let clear_graph () =
    let msg =
      object%js
        val funname = Js.string "clear_graph"
      end
    in
    Worker.post_message msg
end

module Eval = Eval.MakeEval (G)

let onmessage event =
  let input = Js.to_string event##.input in
  let () = Eval.reset () in
  let tree = Parser.parse input in
  let _ = Eval.eval_list 0 tree Vm.empty in
  let output = Eval.get_output_string () in
  let msg =
    object%js
      val funname = Js.string "output"
      val output = Js.string output
    end
  in
  Worker.post_message msg

let () = Worker.set_onmessage onmessage
