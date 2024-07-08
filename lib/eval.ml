open Tree
open Printf

module MakeEval (G : Drawer.GraphicsInterface) = struct
  module Drawer = Drawer.MakeDrawer (G)

  exception Error of string

  let drawer = ref (Drawer.init_drawer ())
  let output_string = ref None

  let get_output_string () =
    match !output_string with None -> "" | Some s -> s

  let disable_output_string () = output_string := None

  let reset () =
    output_string := Some "";
    drawer := Drawer.init_drawer ()

  let float_of_value v =
    match v with
    | Value v -> float_of_int v
    | FloatValue f -> f
    | _ -> Error "Failed to convert to float" |> raise

  let int_of_value v =
    match v with
    | Value v -> v
    | FloatValue f -> int_of_float f
    | _ -> Error "Failed to convert to int" |> raise

  let is_value v = match v with Value _ | FloatValue _ -> true | _ -> false
  let indent level = String.make (2 * level) ' '

  let process_binary_op op vm =
    let op2, vm = Vm.pop vm in
    let op1, vm = Vm.pop vm in
    match (op1, op2) with
    | Value v1, Value v2 ->
        let value =
          match op with
          | Add -> Value (v1 + v2)
          | Sub -> Value (v1 - v2)
          | Mul -> Value (v1 * v2)
          | Div -> Value (v1 / v2)
          | Lt -> if v1 < v2 then Value 1 else Value 0
        in
        Vm.push value vm
    | _, _ -> (
        match (is_value op1, is_value op2) with
        | true, true -> (
            let v1 = float_of_value op1 in
            let v2 = float_of_value op2 in
            match op with
            | Add -> Vm.push (FloatValue (v1 +. v2)) vm
            | Sub -> Vm.push (FloatValue (v1 -. v2)) vm
            | Mul -> Vm.push (FloatValue (v1 *. v2)) vm
            | Div -> Vm.push (FloatValue (v1 /. v2)) vm
            | Lt ->
                if v1 < v2 then Vm.push (Value 1) vm else Vm.push (Value 0) vm)
        | _, _ ->
            vm |> Vm.sprint_vm |> prerr_endline;
            Error "Operands are not values" |> raise)

  let process_def vm =
    let value, vm = Vm.pop vm in
    let key, vm = Vm.pop vm in
    match key with
    | SymbolDecl s -> Vm.save_var s value vm
    | _ ->
        vm |> Vm.sprint_vm |> prerr_endline;
        Error "Wrong def usage" |> raise

  let process_native_fun f vm =
    (drawer :=
       match f with
       | "save" | "restore" | "translate" | "rotate" | "begin_path" | "move_to"
       | "line_to" | "stroke" | "set_fill_style" ->
           Drawer.open_windows_if_needed !drawer
       | _ -> !drawer);
    match f with
    | "dup" ->
        let v, vm = Vm.pop vm in
        vm |> Vm.push v |> Vm.push v
    | "exch" ->
        let v1, vm = Vm.pop vm in
        let v2, vm = Vm.pop vm in
        vm |> Vm.push v1 |> Vm.push v2
    | "puts" -> (
        let v, vm = Vm.pop vm in
        match v with
        | Value v ->
            (match !output_string with
            | None -> printf "PUTS: %i\n%!" v
            | Some os -> output_string := Some (os ^ sprintf "PUTS: %i\n%!" v));
            vm
        | FloatValue f ->
            (match !output_string with
            | None -> printf "PUTS: %f\n%!" f
            | Some os -> output_string := Some (os ^ sprintf "PUTS: %f\n%!" f));
            vm
        | _ ->
            vm |> Vm.sprint_vm |> prerr_endline;
            Error "Not a value" |> raise)
    | "load" -> (
        let v, vm = Vm.pop vm in
        match v with
        | SymbolDecl s ->
            let v = Vm.get_var s vm in
            Vm.push v vm
        | _ ->
            vm |> Vm.sprint_vm |> prerr_endline;
            Error "Not a symbol decl" |> raise)
    | "pi" -> Vm.push (FloatValue Float.pi) vm
    | "save" ->
        drawer := Drawer.save !drawer;
        vm
    | "restore" ->
        drawer := Drawer.restore !drawer;
        vm
    | "translate" ->
        let y, vm = Vm.pop vm in
        let x, vm = Vm.pop vm in
        drawer := Drawer.translate (float_of_value x) (float_of_value y) !drawer;
        vm
    | "rotate" ->
        let r, vm = Vm.pop vm in
        drawer := Drawer.rotate (float_of_value r) !drawer;
        vm
    | "begin_path" ->
        drawer := Drawer.begin_path !drawer;
        vm
    | "move_to" ->
        let y, vm = Vm.pop vm in
        let x, vm = Vm.pop vm in
        drawer := Drawer.move_to (float_of_value x) (float_of_value y) !drawer;
        vm
    | "line_to" ->
        let y, vm = Vm.pop vm in
        let x, vm = Vm.pop vm in
        drawer := Drawer.line_to (float_of_value x) (float_of_value y) !drawer;
        vm
    | "stroke" ->
        drawer := Drawer.stroke !drawer;
        vm
    | "set_fill_style" ->
        let b, vm = Vm.pop vm in
        let g, vm = Vm.pop vm in
        let r, vm = Vm.pop vm in
        drawer :=
          Drawer.set_fill_style (int_of_value r) (int_of_value g)
            (int_of_value b) !drawer;
        vm
    | _ ->
        vm |> Vm.sprint_vm |> prerr_endline;
        Error (sprintf "Unknown function %s" f) |> raise

  let rec eval_token level token vm =
    match token with
    | Operator op -> process_binary_op op vm
    | Block b -> Vm.push (Block b) vm
    | NativeFunc f -> process_native_fun f vm
    | Symbol s -> (
        match Vm.get_var s vm with
        | Block b ->
            (* printf "%sCalling %s with %s\n" (indent level) s (Vm.sprint_vm vm); *)
            let temp_vm : Vm.vm = eval_list (level + 1) b vm in
            (* printf "%sResult %s with %s\n" (indent level) s (Vm.sprint_vm vm); *)
            { vm with stack = temp_vm.stack }
        | t -> eval_token (level + 1) t vm)
    | SymbolDecl s -> Vm.push (SymbolDecl s) vm
    | Value v -> Vm.push (Value v) vm
    | FloatValue f -> Vm.push (FloatValue f) vm
    | If -> process_if level vm
    | Def -> process_def vm

  and eval_list level l vm =
    l |> List.fold_left (fun vm t -> eval_token level t vm) vm

  and process_if level vm =
    let false_block, vm = Vm.pop vm in
    let true_block, vm = Vm.pop vm in
    let cond, vm = Vm.pop vm in
    match (cond, true_block, false_block) with
    | Block c, Block t, Block f -> (
        let vm = eval_list (level + 1) c vm in
        let res, vm = Vm.pop vm in
        match res with
        | Value 1 -> eval_list (level + 1) t vm
        | Value 0 -> eval_list (level + 1) f vm
        | _ ->
            vm |> Vm.sprint_vm |> prerr_endline;
            Error "Condition doesn't return value" |> raise)
    | _, _, _ ->
        vm |> Vm.sprint_vm |> prerr_endline;
        Error "Wronly formed if" |> raise
end
