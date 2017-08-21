#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 6
#define EMPTY 0x0
#define MASK  0x007E7E7E7E7E7E00
#define OUTSIDE_MASK 0xFF818181818181FF
#define FIRST 0x0040000000000000
#define LOOP_MASK 0xFFFFFFFFFFFFFF00

typedef unsigned long long Board;

Board generate_board()
{
  Board board = (unsigned long)rand();
  for (int i = 0; i < 3; i++) {
    board = (board << 16) | ((unsigned long)rand());
  }
  return board & MASK;
}

void add(Board b1, Board b2, Board b3, Board *c, Board *s)
{
  *s = b1 ^ b2;
  *c = b1 & b2 | *s & b3;
  *s ^= b3;
}

void add2(Board c1, Board s1, Board c2, Board s2, Board *cc, Board *c, Board *s)
{
  *s = s1 ^ s2;
  add(c1, c2, s1 & s2, cc, c);
}

Board next(Board board)
{
  Board c1, s1, c2, s2, c3, s3;
  add(board << 9, board << 8, board << 7, &c1, &s1);
  add(board << 1, EMPTY     , board >> 1, &c2, &s2);
  add(board >> 7, board >> 8, board >> 9, &c3, &s3);
  Board cc4, c4, s4, cc5, c, s;
  add2(c1, s1, c2, s2, &cc4, &c4, &s4);
  add2(c3, s3, c4, s4, &cc5, &c,  &s);
  Board cc = cc4 ^ cc5;
  return MASK & ~cc & c & (board | s);
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
      flag >>= 1;
      continue;
    }
    putchar(board & flag ? '*' : ' ');
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
