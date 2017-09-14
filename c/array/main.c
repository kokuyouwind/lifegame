#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 5
typedef int** Board;

int **generate_board()
{
  int **board = malloc(sizeof(int*) * SIZE);
  for (int i = 0; i < SIZE; i++) {
    board[i] = malloc(sizeof(int) * SIZE);
  }
  return board;
}

void init_board(Board board)
{
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      board[i][j] = rand() % 2;
    }
  }
}

int find(Board board, int i, int j)
{
  if (i < 0 || i >= SIZE) { return 0; }
  if (j < 0 || j >= SIZE) { return 0; }
  return board[i][j];
}

void next(Board board, Board next_board)
{
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      int count =
        find(board, i-1, j-1) + find(board, i-1, j)   + find(board, i-1, j+1) +
        find(board, i  , j-1)                         + find(board, i  , j+1) +
        find(board, i+1, j-1) + find(board, i+1, j)   + find(board, i+1, j+1);
      if (board[i][j] == 0 && count == 3) {
        next_board[i][j] = 1;
      } else if (board[i][j] == 1 && (count == 2 || count == 3)) {
        next_board[i][j] = 1;
      } else {
        next_board[i][j] = 0;
      }
    }
  }
}

int board_equal(Board board, Board next_board)
{
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      if (board[i][j] != next_board[i][j]) {
        return 0;
      }
    }
  }
  return 1;
}

void print_separator(int step)
{
  printf("==%d==\n", step);
}

void print_board(Board board)
{
  for(int i = 0; i < SIZE; i++) {
    for(int j = 0; j < SIZE; j++) {
      putchar(board[i][j] ? '*' : ' ');
    }
    putchar('\n');
  }
}

void swap_boards(Board* board, Board* next_board)
{
  void* tmp = *board;
  *board = *next_board;
  *next_board = tmp;
}

void free_board(Board board)
{
  for (int i = 0; i < SIZE; i++) {
    free(board[i]);
  }
  free(board);
}

int main()
{
  srand(time(NULL));

  int step = 0;
  Board board = generate_board(), next_board = generate_board(), tmp;
  init_board(board);

  do {
    print_separator(step++);
    print_board(board);
    next(board, next_board);
    swap_boards(&board, &next_board);
  } while (!board_equal(board, next_board));

  free_board(board);
  free_board(next_board);
  return 0;
}
