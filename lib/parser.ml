open Opal
open Tree

exception ParserError of string

let none_of l = satisfy (fun x -> not (List.mem x l))

let rec token_list l input =
  match l with
  | [] -> None
  | hd :: tl -> (
      match token hd input with
      | Some _ as res -> res
      | None -> token_list tl input)

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

let comment = token "#" >> many (none_of ['\n']) => implode >>= fun x ->
  optional (token "\n") >> return (Comment x)

let native_fun =
  token_list
    [
      "exch";
      "dup";
      "puts";
      "load";
      "pi";
      "save";
      "restore";
      "translate";
      "rotate";
      "begin_path";
      "move_to";
      "line_to";
      "stroke";
      "set_fill_style";
    ]
  => fun x -> NativeFunc x

let rec tok input =
  many
    (comment
    <|> (block tok => (fun x -> Block x))
    <|> if_token <|> def <|> native_fun <|> symbol_decl <|> float_val
    <|> integer <|> operator <|> symbol)
    input

let parse input =
  match parse tok (LazyStream.of_string input) with
  | Some ans -> ans
  | None -> ParserError "Failed to parse" |> raise
