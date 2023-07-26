open Graphics
open Printf

type drawer = {
  origin_pos : float * float * float;
  cur_pos : float * float;
  stack : (float * float) list;
  saved : drawer list;
}

exception DrawerError of string

let sprintf_point pt =
  let x, y = pt in
  sprintf "(%0.2f, %0.2f)" x y

let sprintf_drawer drawer =
  let ox, oy, orig_r = drawer.origin_pos in
  let x, y = drawer.cur_pos in
  sprintf
    "{origin = (%0.2f, %0.2f, %0.2f), cur_pos = (%0.2f, %0.2f), stack = [%s], \
     saved = %i}"
    ox oy orig_r x y
    (drawer.stack |> List.map sprintf_point |> String.concat ",")
    (drawer.saved |> List.length)

let init_drawer =
  { origin_pos = (0., 0., 0.); cur_pos = (0., 0.); stack = []; saved = [] }

let transform origin_pos pt =
  let ox, oy, origin_r = origin_pos in
  let x, y = pt in
  let nx = ox +. (cos origin_r *. x) +. (sin origin_r *. y) in
  let ny = oy -. (sin origin_r *. x) +. (cos origin_r *. y) in
  (nx, ny)

let translate x y drawer =
  let ox, oy, origin_r = drawer.origin_pos in
  let x, y = transform (0., 0., origin_r) (x, y) in
  { drawer with origin_pos = (ox +. x, oy +. y, origin_r) }

let rotate r drawer =
  let ox, oy, origin_r = drawer.origin_pos in
  { drawer with origin_pos = (ox, oy, origin_r +. r) }

let move_to x y drawer = { drawer with cur_pos = (x, y) }

let line_to x y drawer =
  {
    drawer with
    stack =
      transform drawer.origin_pos (x, y)
      :: transform drawer.origin_pos drawer.cur_pos
      :: drawer.stack;
  }

let begin_path drawer = { drawer with stack = [] }

let stroke drawer =
  let rec process stack =
    match stack with
    | [] -> { drawer with stack = [] }
    | end_pt :: start_pt :: tl ->
        let s_x, s_y = start_pt in
        let e_x, e_y = end_pt in
        let () = moveto (int_of_float s_x) (int_of_float s_y) in
        let () = lineto (int_of_float e_x) (int_of_float e_y) in
        process tl
    | _ -> DrawerError "Unexpected error" |> raise
  in
  process drawer.stack

let save drawer = { drawer with saved = drawer :: drawer.saved }

let restore drawer =
  match drawer.saved with
  | [] -> DrawerError "No saved drawer to restore" |> raise
  | hd :: tl -> { hd with saved = tl }
