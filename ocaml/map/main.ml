let rec range n m =
  if n > m then []
  else n::(range (n+1) m)
let rec fix f x =
  let x' = f x in
  if x = x' then () else fix f x'

module Position = struct
  type t = int * int
  let compare = compare
  let origin = (1, 1)
end

module PositionSet = struct
  include Set.Make(Position)
  let range (n1, m1) (n2, m2) =
    List.fold_right (fun n ->
      List.fold_right (fun m -> add (n, m)) @@ range m1 m2
    ) (range n1 n2) empty
  let neighbors (n, m) =
    remove (n, m) @@ range (n-1, m-1) (n+1, m+1)
end

module Cell = struct
  type t = int
  let live = 1
  let dead = 0

  let generate () = Random.int 2
  let to_string cell = if cell = live then "*" else " "
  let next = function
    | (0, 3) -> live
    | (1, 2) -> live
    | (1, 3) -> live
    | otherwise -> dead
end

module Board = struct
  include Map.Make(Position)
  let generate n =
    PositionSet.fold (fun key -> add key @@ Cell.generate ()) (PositionSet.range Position.origin (n,n)) empty

  let find_or_dead p board =
    try find p board
    with
    | Not_found -> Cell.dead
    | _ -> failwith "Unknown Error"

  let max_key board =
    let key, _ = max_binding board in key
  let size board =
    let n, _ = max_key board in n
  let dimentional_range board =
    range 1 @@ size board

  let next board =
    let neighbors_count p =
      PositionSet.fold (fun p' -> (+) @@ find_or_dead p' board) (PositionSet.neighbors p) 0
    in
      mapi (fun p cell -> Cell.next (cell, neighbors_count p)) board

  let to_string board =
    let to_string_cell i j =
      Cell.to_string @@ find_or_dead (i, j) board
    in
    let to_string_line i =
      List.fold_left (fun acc j -> acc ^ (to_string_cell i j)) "" @@ dimentional_range board
    in
    List.fold_left (fun acc i -> acc ^ (to_string_line i) ^ "\n") "" @@ dimentional_range board
  let print board = print_string @@ to_string board

  let run =
    let step = ref 0 in
    let print_separator () = (Printf.printf "==%i==\n" !step; step := !step +1) in
    fix (fun board -> print_separator (); print board; next board)
end

let () = Random.self_init ()
let () = Board.run @@ Board.generate 5
