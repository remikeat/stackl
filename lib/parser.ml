open Opal
open Tree

exception ParserError of string

let identifier = letter <~> many (alpha_num <|> exactly '_') => implode
let block x = lexeme (between (token "{") (token "}") x)
let integer = lexeme (many1 digit => implode => fun x -> Value (int_of_string x))
let add = token "+" >> return Add
let sub = token "-" >> return Sub
let mul = token "*" >> return Mul
let div = token "/" >> return Div
let lt = token "<" >> return Lt
let operator = add <|> sub <|> mul <|> div <|> lt => fun x -> Operator x
let symbol = lexeme identifier => fun x -> Symbol x
let symbol_decl = token "/" >> identifier => fun x -> SymbolDecl x
let if_token = token "if" >> return If
let def = token "def" >> return Def

let native_fun =
  token "exch" >> return (NativeFunc "exch")
  <|> (token "dup" >> return (NativeFunc "dup"))
  <|> (token "puts" >> return (NativeFunc "puts"))

let rec tok input =
  many1
    (block tok
    => (fun x -> Block x)
    <|> if_token <|> def <|> native_fun <|> symbol_decl <|> operator <|> integer
    <|> symbol)
    input

let parse input =
  match parse tok (LazyStream.of_string input) with
  | Some ans -> ans
  | None -> ParserError "Failed to parse" |> raise
