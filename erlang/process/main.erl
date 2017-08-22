-module(main).
-export([main/0]).

-define(SIZE, 5).

publish_status(_, _, []) -> ok;
publish_status(Step, Status, [Node|Rest]) ->
  Node ! {status, Step, Status},
  publish_status(Step, Status, Rest).

count_livings(_, 0, Count) -> Count;
count_livings(Step, N, Count) ->
  receive
    {status, S, Status} when S == Step ->
      if
        Status -> count_livings(Step, N-1, Count+1);
        true -> count_livings(Step, N-1, Count)
      end
  end.
count_livings(Step, Neighbors) ->
  count_livings(Step, length(Neighbors), 0).

next_status(_, 3) -> true;
next_status(true, 2) -> true;
next_status(_, _) -> false.

cell(Board, Step, Pos, Status, Neighbors) ->
  Board ! {Step, Pos, Status},
  publish_status(Step, Status, Neighbors),
  NextStatus = next_status(Status, count_livings(Step, Neighbors)),
  cell(Board, Step+1, Pos, NextStatus, Neighbors).

generate_cell(Board, {X, Y} = Pos) ->
  receive
    {add_neighbors, Cells} ->
      Neighbors = lists:filtermap(
        fun({{X2, Y2}, Cell}) ->
          if
            X == X2, Y == Y2 -> false;
            abs(X - X2) =< 1, abs(Y - Y2) =< 1 -> {true, Cell};
            true -> false
          end
        end, Cells),
      Status = rand:uniform() >= 0.5,
      cell(Board, 1, Pos, Status, Neighbors)
  end.

generate_cells(_, Cells, {0, _}) ->
  lists:foreach(fun({_, Cell}) -> Cell ! {add_neighbors, Cells} end, Cells);
generate_cells(Board, Cells, {X, 0}) ->
  generate_cells(Board, Cells, {X-1, ?SIZE});
generate_cells(Board, Cells, {X, Y} = Pos) ->
  generate_cells(Board, [{Pos, spawn(fun() -> generate_cell(Board, Pos) end)} | Cells], {X, Y-1}).
generate_cells(Board) -> generate_cells(Board, [], {?SIZE, ?SIZE}).

aggregate_board(_, {0, _}, _, Board) ->
  Board;
aggregate_board(Step, {X, 0}, Col, Board) ->
  aggregate_board(Step, {X-1, ?SIZE}, [], [Col|Board]);
aggregate_board(Step, {X, Y}, Col, Board) ->
  receive
    {S, {X2, Y2}, Status} when S == Step, X == X2, Y == Y2 ->
      aggregate_board(Step, {X, Y-1}, [Status|Col], Board)
  end.
aggregate_board(Step) -> aggregate_board(Step, {?SIZE, ?SIZE}, [], []).

print_column([]) -> io:nl();
print_column([true|Rest]) -> io:format("*"), print_column(Rest);
print_column([false|Rest]) -> io:format(" "), print_column(Rest).

print_board([]) -> ok;
print_board([Col|Cols]) -> print_column(Col), print_board(Cols).

print_separator(Step) -> io:format("==~B==~n", [Step]).

board(Step, BeforeBoard, Pid) ->
  Board = aggregate_board(Step),
  if
    BeforeBoard == Board -> Pid ! ok;
    true -> {
      print_separator(Step),
      print_board(Board),
      board(Step+1, Board, Pid)
    }
  end.

generate_board(Pid) ->
  Board = spawn(fun() -> board(1, empty, Pid) end),
  generate_cells(Board).

main()->
  generate_board(self()),
  receive
    ok -> return
  end.
