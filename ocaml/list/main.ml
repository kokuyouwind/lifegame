let rec genboard h w =
  let rec gencolumn w =
    if w <= 0 then []
    else (Random.int 2)::(gencolumn(w-1))
  in
  if h <= 0 then []
  else (gencolumn w)::(genboard (h-1) w)

let to_string board =
  let to_string_col col =
    List.fold_right (fun x acc -> (if x = 1 then "*" else ".") ^ acc ) col "\n"
  in
  List.fold_left (fun acc col -> acc ^ (to_string_col col)) "" board

let next = function
  | [l1; [x1; x2; x3]; l2] ->
    let sum = List.fold_left (+) 0 in
    let count =  sum l1 + sum l2 + x1 + x3 in
      if count = 3 || x2 = 1 && count = 2 then 1 else 0
  | otherwise -> failwith "error"

let group zero l =
  let rec group' = function
    | h1::h2::h3::rest -> [h1; h2; h3]::(group' (h2::h3::rest))
    | h1::h2::[] -> [h1; h2; zero]::[]
    | otherwize -> failwith "error"
  in group' (zero::l)

let trans l =
  let rec trans' acc = function
    | h::t -> trans' (List.map2 (fun x l -> x::l) h acc) t
    | [] -> List.map List.rev acc
  in trans' (List.map (fun _ -> []) @@ List.hd l) l

let next_board board = board
  |> List.map (group 0)
  |> trans
  |> List.map (group [0;0;0])
  |> trans
  |> List.map (List.map next)

let run board =
  let rec run' board step =
    let () = Printf.printf "==%i==\n" step in
    let () = board |> to_string |> print_string in
    let board' = next_board board in
    if board = board' then ()
    else run' board' (step + 1)
  in run' board 1

let () = Random.self_init ()
let () = run @@ genboard 5 5
