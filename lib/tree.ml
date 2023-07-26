open Printf

type operator = Add | Sub | Mul | Div | Lt

type tree =
  | Value of int
  | FloatValue of float
  | Symbol of string
  | SymbolDecl of string
  | Operator of operator
  | Block of tree list
  | NativeFunc of string
  | If
  | Def

let rec sprint_tree tree_lst =
  tree_lst
  |> List.map (fun v ->
         match v with
         | Value v -> sprintf "Value %i" v
         | FloatValue v -> sprintf "FloatValue %f" v
         | If -> sprintf "if"
         | Def -> sprintf "def"
         | Operator op -> (
             match op with
             | Add -> sprintf "+"
             | Sub -> sprintf "-"
             | Mul -> sprintf "*"
             | Div -> sprintf "div"
             | Lt -> sprintf "<")
         | Block b -> sprintf "Block [%s]" (sprint_tree b)
         | Symbol s -> sprintf "Symbol %s" s
         | SymbolDecl s -> sprintf "SymbolDecl %s" s
         | NativeFunc f -> sprintf "NativeFunc %s" f)
  |> String.concat ", " |> sprintf "[%s]"
