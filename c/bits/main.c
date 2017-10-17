#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 6
#define MASK  0x007E7E7E7E7E7E00
#define OUTSIDE_MASK 0xFF818181818181FF
#define FIRST 0x0040000000000000
#define LOOP_MASK 0xFFFFFFFFFFFFFF00

typedef unsigned long long Board;

int popcount(Board bits)
{
    bits = (bits & 0x5555555555555555) + (bits >> 1 & 0x5555555555555555);
    bits = (bits & 0x3333333333333333) + (bits >> 2 & 0x3333333333333333);
    bits = (bits & 0x0f0f0f0f0f0f0f0f) + (bits >> 4 & 0x0f0f0f0f0f0f0f0f);
    bits = (bits & 0x00ff00ff00ff00ff) + (bits >> 8 & 0x00ff00ff00ff00ff);
    bits = (bits & 0x0000ffff0000ffff) + (bits >> 16 & 0x0000ffff0000ffff);
    bits = (bits & 0x00000000ffffffff) + (bits >> 32 & 0x00000000ffffffff);
    return (int)bits;
}

Board generate_board()
{
  Board board = (unsigned long)rand();
  for (int i = 0; i < 3; i++) {
    board = (board << 16) | ((unsigned long)rand());
  }
  return board & MASK;
}

Board next(Board board)
{
  Board next_board = 0;
  Board neighbors_mask = 0xE0A0E00000000000;

  for(Board flag = FIRST; flag & LOOP_MASK; flag >>= 1, neighbors_mask >>= 1) {
    if (flag & OUTSIDE_MASK) { continue; }
    int count = popcount(board & neighbors_mask);
    if (!((count | popcount(board & flag)) ^ 3)) {
      next_board |= flag;
    }
  }

  return next_board;
}

void print_separator(int step)
{
  printf("==%d==\n", step);
}

void print_board(Board board)
{
  for(Board flag = FIRST; flag & LOOP_MASK; flag >>= 1) {
    if (flag & OUTSIDE_MASK) {
      putchar('\n');
      flag >>= 2;
    }
    putchar(board & flag ? '*' : '.');
  }
}

int main()
{
  srand(time(NULL));

  Board board = 0ull;
  Board next_board = generate_board();

  for(int step = 0; board ^ next_board; step++) {
    board = next_board;
    print_separator(step);
    print_board(board);
    next_board = next(board);
  }
}
