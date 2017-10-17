#!/usr/bin/env swipl

:- initialization(main, main).

range(Low, Hi, []) :- Low > Hi, !.
range(Low, Hi, [Low|Rest]) :- Low1 is Low + 1, range(Low1, Hi, Rest).

indexes(List) :- range(1, 5, List).
index(Index) :- indexes(List), member(Index, List).

position((X, Y)) :- index(X), index(Y).
positions(List) :- findall(P, position(P), List).

sum([Sum], Sum).
sum([H1,H2|T], Sum) :- H is H1 + H2, sum([H|T], Sum).

celldef(Step, P, Status) :- asserta(cell(Step, P, Status) :- !).

self(0, 0).
neighbors_diff(XDiff, YDiff) :- range(-1, 1, Range), member(XDiff, Range), member(YDiff, Range), not(self(XDiff, YDiff)).

neighbor(Step, (X, Y), Status) :-
  neighbors_diff(XDiff, YDiff), X1 is X + XDiff, Y1 is Y + YDiff, cell(Step, (X1, Y1), Status).
count_neighbors(Step, P, Count) :-
  findall(Status, neighbor(Step, P, Status), List), sum(List, Count).

next_status(0, 3, 1) :- !.
next_status(1, 2, 1) :- !.
next_status(1, 3, 1) :- !.
next_status(_, _, 0).

cell(_, P, 0) :- not(position(P)), !.
cell(1, P, Status) :- !, Status is random(2), celldef(1, P, Status).
cell(Step, P, Status) :-
  Step1 is Step - 1, cell(Step1, P, Status1), count_neighbors(Step1, P, Count),
  next_status(Status1, Count, Status), !, celldef(Step, P, Status).

print_status(0) :- format(".").
print_status(1) :- format("*").
print_cell(Step, P) :- cell(Step, P, Status), print_status(Status).
print_line(Step, X) :- foreach(index(Y), print_cell(Step, (X, Y))), format("~n").
print_board(Step) :- foreach(index(X), print_line(Step, X)).
print_step(Step) :- format("==~d==~n", Step), print_board(Step).

stable_cell(Step, P) :- Step1 is Step + 1, cell(Step1, P, Status), cell(Step, P, Status).
fix_step(Step) :- forall(position(P), stable_cell(Step, P)), !, print_step(Step).
fix_step(Step) :- print_step(Step), Step1 is Step + 1, fix_step(Step1).

main :-
  fix_step(1).
