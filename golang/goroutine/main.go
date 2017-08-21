package main

import (
	"fmt"
	"math/rand"
	"time"
	"sync"
	"reflect"
)

const Size = 5
type Position struct {
	x int
	y int
}
type Status struct {
	position Position
	value int
}
type Board map[Position] int

func positions() <-chan Position {
	ch := make(chan Position)
	go func() {
		for x := 0; x < Size; x++ {
			for y := 0; y < Size; y++ {
				ch <- Position{x, y}
			}
		}
		close(ch)
	} ()
	return ch
}

func neighborPositions(position Position) <-chan Position {
	ch := make(chan Position)
	go func() {
		for dx := -1; dx <= 1; dx++ {
			for dy := -1; dy <= 1; dy++ {
				if dx == 0 && dy == 0 { continue }
				x := position.x + dx
				y := position.y + dy
				if x < 0 || x >= Size || y < 0 || y >= Size { continue }
				ch <- Position{x, y}
			}
		}
		close(ch)
	} ()
	return ch
}

func initBoard() Board {
	rand.Seed(time.Now().UnixNano())
	board := make(Board, Size * Size)
	for position := range positions() {
		board[position] = rand.Intn(2)
	}
	return board
}

func printBoard(board Board) {
	for position := range positions() {
		if board[position] == 1 {
			fmt.Print("*")
		} else {
			fmt.Print(" ")
		}
		if position.y == Size - 1 {
			fmt.Print("\n")
		}
	}
}

func calcNextCell(board Board, position Position) int {
	count := 0
	for neighborPosition := range neighborPositions(position) {
		count += board[neighborPosition]
	}
	if (board[position] == 1 && count == 2) || count == 3 {
		return 1
	} else {
		return 0
	}
}

func nextBoard(board Board) Board {
	next := make(Board, Size * Size)
	update := make(chan Status)
	done := make(chan struct{})
	go func() {
		var wg sync.WaitGroup
		for position := range positions() {
			wg.Add(1)
			go func(position Position) {
				update <- Status{position, calcNextCell(board, position)}
				wg.Done()
			} (position)
		}
		wg.Wait()
		close(done)
	} ()
	for {
		select {
		case status := <- update:
			next[status.position] = status.value
		case <- done:
			return next
		}
	}
}

func printSeparator(step int) {
	fmt.Printf("==%d==\n", step)
}

func main() {
	board := initBoard()
	for step := 0; ; step++ {
		printSeparator(step)
		printBoard(board)
		next := nextBoard(board)
		if reflect.DeepEqual(board, next) {
			return
		}
		board = next
	}
}
