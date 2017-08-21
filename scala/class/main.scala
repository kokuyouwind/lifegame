object Cell {
  val random = new scala.util.Random
  val cells = IndexedSeq(DeadCell, LiveCell)
  def generate = cells(random.nextInt(2))
  def apply(live: Boolean): Cell = if(live) { LiveCell } else { DeadCell }
}

abstract class Cell {
  def countLive: Int
  def next(liveCount: Int): Cell
}

object LiveCell extends Cell {
  override def toString = "*"
  val countLive = 1
  def next(liveCount: Int) = Cell(liveCount == 2 || liveCount == 3)
}

object DeadCell extends Cell {
  override def toString = " "
  val countLive = 0
  def next(liveCount: Int) = Cell(liveCount == 3)
}

object Column {
  def apply(size: Int) = new Column(IndexedSeq.tabulate(size)(_ => Cell.generate))
}

case class Column(val cells: Seq[Cell]) {
  override def toString = cells.foldLeft("")((acc, cell) => acc + cell.toString)
  def countLive(center: Int) = cells.slice(center-1, center+2).map(_.countLive).sum
  def map(f: ((Cell, Int)) => Cell): Column = new Column(cells.zipWithIndex.map(f))
}

object Board {
  def apply(size: Int) = new Board(IndexedSeq.tabulate(size)(_ => Column(size)))
}

case class Board(val cols: Seq[Column]) {
  override def toString = cols.foldLeft("")((acc, col) => acc + col.toString + "\n")
  def countLive(colIdx: Int, CellIdx: Int) =
    cols.slice(colIdx-1, colIdx+2).map(_.countLive(CellIdx)).sum
  def map(f: ((Int, Int, Cell)) => Cell) =
    new Board(cols.zipWithIndex.map({ case (col, colIdx) =>
      col.map { case (cell, cellIdx) => f(colIdx, cellIdx, cell)}
    }))
  lazy val next = map { case (colIdx, cellIdx, cell) =>
    val liveNeighborsCount = countLive(colIdx, cellIdx) - cell.countLive
    cell.next(liveNeighborsCount)
  }
  lazy val isFreezed = this == next
  val stream: Stream[Board] = this #:: (if (isFreezed) { Stream.empty } else { next.stream })
}

object Main{
  def print_separator(step: Int) = printf("==%d==\n", step)

  def main(args: Array[String]){
    for ((board, step) <- Board(5).stream.zipWithIndex) {
      print_separator(step)
      printf(board.toString)
    }
  }
}
