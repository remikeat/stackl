open Printf
open Tree

exception Error of string

let process_binary_op op vm =
  let op2, vm = Vm.pop vm in
  let op1, vm = Vm.pop vm in
  let res =
    match (op1, op2) with
    | Value v1, Value v2 -> (
        match op with
        | Add -> v1 + v2
        | Sub -> v1 - v2
        | Mul -> v1 * v2
        | Div -> v1 / v2
        | Lt -> if v1 < v2 then 1 else 0)
    | _, _ -> Error "Operands are not values" |> raise
  in
  Vm.push (Value res) vm

let process_def vm =
  let value, vm = Vm.pop vm in
  let key, vm = Vm.pop vm in
  match key with
  | SymbolDecl s -> Vm.save_var s value vm
  | _ -> Error "Wrong def usage" |> raise

let process_native_fun f vm =
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
          printf "PUTS: %i\n" v;
          vm
      | _ -> Error "Not a value" |> raise)
  | _ -> Error (sprintf "Unknown function %s" f) |> raise

let rec eval_token token vm =
  match token with
  | Operator op -> process_binary_op op vm
  | Block b -> Vm.push (Block b) vm
  | NativeFunc f -> process_native_fun f vm
  | Symbol s -> (
      match Vm.get_var s vm with
      | Block b ->
          let temp_vm : Vm.vm = eval_list b vm in
          { vm with stack = temp_vm.stack }
      | t -> eval_token t vm)
  | SymbolDecl s -> Vm.push (SymbolDecl s) vm
  | Value v -> Vm.push (Value v) vm
  | If -> process_if vm
  | Def -> process_def vm

and eval_list l vm = l |> List.fold_left (fun vm t -> eval_token t vm) vm

and process_if vm =
  let false_block, vm = Vm.pop vm in
  let true_block, vm = Vm.pop vm in
  let cond, vm = Vm.pop vm in
  match (cond, true_block, false_block) with
  | Block c, Block t, Block f -> (
      let vm = eval_list c vm in
      let res, vm = Vm.pop vm in
      match res with
      | Value 1 -> eval_list t vm
      | Value 0 -> eval_list f vm
      | _ -> Error "Condition doesn't return value" |> raise)
  | _, _, _ -> Error "Wronly formed if" |> raise

let read_lines () =
  let rec read_lines' acc =
    try
      let line = input_line stdin in
      read_lines' (line :: acc)
    with End_of_file -> acc |> List.rev
  in
  read_lines' [] |> String.concat "\n"

let input = read_lines ()
let tree = Parser.parse input
let vm = eval_list tree Vm.empty
