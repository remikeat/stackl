open Js_of_ocaml
module Events = Js_of_ocaml_lwt.Lwt_js_events
module Html = Dom_html

module G = struct
  type color = Graphics_js.color

  let open_graph_area () = ()

  let moveto x y =
    let msg =
      object%js
        val fun_name = "moveto"
        val x = x
        val y = y
      end
    in
    Worker.post_message msg

  let lineto x y =
    let msg =
      object%js
        val fun_name = "lineto"
        val x = x
        val y = y
      end
    in
    Worker.post_message msg

  let set_color color =
    let msg =
      object%js
        val fun_name = "set_color"
        val color = color
      end
    in
    Worker.post_message msg

  let fill_poly coords =
    let msg =
      object%js
        val fun_name = "fill_poly"
        val coords = coords
      end
    in
    Worker.post_message msg

  let rgb = Graphics_js.rgb

  let clear_graph () =
    let msg =
      object%js
        val fun_name = "clear_graph"
      end
    in
    Worker.post_message msg
end

module Eval = Eval.MakeEval (G)

let onmessage event =
  let input = event##.input in
  let () = Eval.reset () in
  let tree = Parser.parse input in
  let _ = Eval.eval_list 0 tree Vm.empty in
  let output = Eval.get_output_string () in
  let msg =
    object%js
      val fun_name = "output"
      val output = output
    end
  in
  Worker.post_message msg

let () = Worker.set_onmessage onmessage
