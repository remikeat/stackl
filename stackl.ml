open Drawer
open Eval
open Input

let input = read_lines ()
let tree = Parser.parse input

(* let () = tree |> sprint_tree |> print_endline *)
let vm = eval_list 0 tree Vm.empty
let () = if !drawer.window_opened then interactive ()
