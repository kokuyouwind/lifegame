#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 5

int **generate_board()
{
  int **board = malloc(sizeof(int*) * SIZE);
  for (int i = 0; i < SIZE; i++) {
    board[i] = malloc(sizeof(int) * SIZE);
  }
  return board;
}

void init_board(int **board)
{
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      board[i][j] = rand() % 2;
    }
  }
}

int find(int **board, int i, int j)
{
  if (i < 0 || i >= SIZE) { return 0; }
  if (j < 0 || j >= SIZE) { return 0; }
  return board[i][j];
}

void next(int **board, int **next_board)
{
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      int count =
        find(board, i-1, j-1) +
        find(board, i-1, j)   +
        find(board, i-1, j+1) +
        find(board, i  , j-1) +
        find(board, i  , j+1) +
        find(board, i+1, j-1) +
        find(board, i+1, j)   +
        find(board, i+1, j+1);
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

int board_equal(int **board, int **next_board)
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

void print_board(int **board)
{
  for(int i = 0; i < SIZE; i++) {
    for(int j = 0; j < SIZE; j++) {
      putchar(board[i][j] ? '*' : ' ');
    }
    putchar('\n');
  }
}

void free_board(int **board)
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
  int **board = generate_board();
  int **tmp;
  int **next_board = generate_board();
  init_board(board);

  do {
    print_separator(step++);
    print_board(board);
    next(board, next_board);

    /* swap */
    tmp = board;
    board = next_board;
    next_board = tmp;
  } while (!board_equal(board, next_board));

  free_board(board);
  free_board(next_board);
  return 0;
}
