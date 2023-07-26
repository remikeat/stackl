open Opal
open Tree

exception ParserError of string

let identifier = letter <~> many (alpha_num <|> exactly '_') => implode
let block x = lexeme (between (token "{") (token "}") x)

let float_val =
  lexeme
    ( option '+' (exactly '-') <~> many digit >>= fun lhs ->
      exactly '.' >> many digit >>= fun rhs ->
      return (lhs @ [ '.' ] @ rhs) => implode => fun x ->
      FloatValue (float_of_string x) )

let integer =
  lexeme
    ( option '+' (exactly '-') <~> many1 digit => implode => fun x ->
      Value (int_of_string x) )

let add = token "+" >> return Add
let sub = token "-" >> return Sub
let mul = token "*" >> return Mul
let div = token "div" >> return Div
let lt = token "<" >> return Lt
let operator = add <|> sub <|> mul <|> div <|> lt => fun x -> Operator x
let symbol = lexeme identifier => fun x -> Symbol x
let symbol_decl = token "/" >> identifier => fun x -> SymbolDecl x
let if_token = token "if" >> return If
let def = token "def" >> return Def

let native_fun =
  token "exch"
  => (fun x -> NativeFunc x)
  <|> (token "dup" => fun x -> NativeFunc x)
  <|> (token "puts" => fun x -> NativeFunc x)
  <|> (token "pi" => fun x -> NativeFunc x)
  <|> (token "save" => fun x -> NativeFunc x)
  <|> (token "restore" => fun x -> NativeFunc x)
  <|> (token "translate" => fun x -> NativeFunc x)
  <|> (token "rotate" => fun x -> NativeFunc x)
  <|> (token "begin_path" => fun x -> NativeFunc x)
  <|> (token "move_to" => fun x -> NativeFunc x)
  <|> (token "line_to" => fun x -> NativeFunc x)
  <|> (token "stroke" => fun x -> NativeFunc x)

let rec tok input =
  many1
    (block tok
    => (fun x -> Block x)
    <|> if_token <|> def <|> native_fun <|> symbol_decl <|> float_val
    <|> integer <|> operator <|> symbol)
    input

let parse input =
  match parse tok (LazyStream.of_string input) with
  | Some ans -> ans
  | None -> ParserError "Failed to parse" |> raise
