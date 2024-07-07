let read_lines () =
  let rec read_lines' acc =
    try
      let line = input_line stdin in
      read_lines' (line :: acc)
    with End_of_file -> acc |> List.rev
  in
  read_lines' [] |> String.concat "\n"
