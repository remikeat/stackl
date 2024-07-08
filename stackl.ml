open Input

module G = struct
  include Graphics

  let open_graph_area () = open_graph " 1024x800"
end

module Eval = Eval.MakeEval (G)

let rec interactive () =
  let event = Graphics.wait_next_event [ Graphics.Key_pressed ] in
  if event.key == 'q' then exit 0 else print_char event.key;
  print_newline ();
  interactive ()

let input = read_lines ()
let tree = Parser.parse input

(* let () = tree |> sprint_tree |> print_endline *)
let vm = Eval.eval_list 0 tree Vm.empty
let () = if !Eval.drawer.window_opened then interactive ()
