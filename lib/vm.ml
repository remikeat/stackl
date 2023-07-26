open Printf
open Tree
module StringMap = Map.Make (String)

type vm = { vars : tree StringMap.t; stack : tree list }

exception VMError of string

let sprint_vars vars =
  vars |> StringMap.bindings
  |> List.map (fun (s, v) ->
         match v with Value v -> sprintf "%s = %i" s v | _ -> sprintf "%s" s)
  |> String.concat ", " |> sprintf "[%s]"

let sprint_vm vm =
  sprintf "{vars = %-20s | stack = %s}" (sprint_vars vm.vars)
    (vm.stack |> sprint_tree)

let empty = { stack = []; vars = StringMap.empty }
let push v vm = { vm with stack = v :: vm.stack }

let pop vm =
  match vm.stack with
  | [] -> VMError "No element to pop" |> raise
  | hd :: tl -> (hd, { vm with stack = tl })

let save_var key v vm = { vm with vars = StringMap.add key v vm.vars }

let get_var key vm =
  match StringMap.find_opt key vm.vars with
  | None -> VMError (sprintf "Symbol '%s' doesn't exist" key) |> raise
  | Some v -> v
