module Cell = struct
  type t = int

  let generate _ = Random.int 2
  let to_string cell = if cell = 1 then "*" else "."
  let separator = ""
  let next count cell = if count = 3 || cell = 1 && count = 2 then 1 else 0
  let sum cell = cell
  let zero = 0
end

module type Elm = sig
  type t
  val generate : int -> t
  val to_string : t -> string
  val separator : string
end

module ElmList(E: Elm) = struct
  type t = E.t list
  let generate n =
    let rec generate' = function
      | 0 -> []
      | m -> (E.generate n)::(generate' @@ m-1)
    in generate' n
  let to_string = List.fold_left (fun acc e -> acc ^ E.to_string e ^ E.separator) ""
  let print e = print_string @@ to_string e
end

module type Colony = sig
  type t
  val zero : t
  val sum : t -> int
  val next : int -> t -> Cell.t
end

module ColonyList(C: Colony) = struct
  type t = C.t list
  let zero = [C.zero; C.zero; C.zero]
  let sum = List.fold_left (fun acc e -> acc + C.sum e) 0
  let next count = function
    | [c1; c2; c3] -> C.next (count + C.sum c1 + C.sum c3) c2
    | otherwise -> failwith "error"
  let make l =
    let rec make' = function
      | h1::h2::h3::rest -> [h1; h2; h3]::(make' (h2::h3::rest))
      | h1::h2::[] -> [h1; h2; C.zero]::[]
      | otherwize -> failwith "error"
    in make' (C.zero::l)
end

module LineColony = struct
  include ColonyList(Cell)
end

module BoardColony = struct
  include ColonyList(LineColony)
end

module Column = struct
  include ElmList(Cell)
  let separator = "\n"
end

module Matrix = struct
  let trans l =
    let rec trans' acc = function
      | h::t -> trans' (List.map2 (fun x l -> x::l) h acc) t
      | [] -> List.map List.rev acc
    in trans' (List.map (fun _ -> []) @@ List.hd l) l
  let elemental_map f = List.map @@ List.map f
  let horizontal_map = List.map
  let vertical_map f m = trans @@ List.map f @@ trans m
end

module Board = struct
  include ElmList(Column)
  include Matrix

  let next board = board
    |> horizontal_map LineColony.make
    |> vertical_map BoardColony.make
    |> elemental_map @@ BoardColony.next 0

  let run board =
    let rec run' board step =
      let () = Printf.printf "==%i==\n" step in
      let () = print board in
      let board' = next board in
        if board = board' then ()
        else run' board' (step + 1)
    in run' board 1
end

let () = Random.self_init ()
let () = Board.run @@ Board.generate 5
