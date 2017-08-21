object Clock {
  abstract class Event
  object Prepare extends Event
  object Update extends Event
  object Cleanup extends Event
  val eventSequence = Seq(Prepare, Update, Cleanup)

  trait Subscriber {
    Clock.subscribe(this)
    def onEvent(event: Event) = ()
  }

  var subscribers: Set[Subscriber] = Set.empty
  def subscribe(subscriber: Subscriber) = subscribers += subscriber

  private var step = 0
  def getStep = step

  private var running = false
  def start = {
    running = true
    while(running) {
      for(event <- eventSequence; subscriber <- subscribers) subscriber.onEvent(event)
      step += 1
    }
  }
  def stop = running = false
}

object ChangeCounter extends Clock.Subscriber {
  private var count = 0
  def countUp = count += 1

  override def  onEvent(event: Clock.Event) = event match {
    case Clock.Prepare => count = 0
    case Clock.Cleanup => if (count == 0) { Clock.stop }
    case _ => ()
  }
}

class Printer(size: Int) extends Clock.Subscriber {
  private val buffers = IndexedSeq.tabulate(size)(_ => new StringBuffer(" " * size + "\n"))
  def update(line: Int, pos: Int, str: String) = buffers(line).replace(pos, pos+1, str)

  override def onEvent(event: Clock.Event) = event match {
    case Clock.Prepare => {
      printf("==%d==\n", Clock.getStep)
      for (buffer <- buffers) printf(buffer.toString)
    }
    case _ => ()
  }
}

object Cell {
  val random = new scala.util.Random
  def createNetwork(printer: Printer, size: Int) = {
    val range = Range(0, size)
    val cells = (for (line <- range; pos <- range) yield (line, pos) -> new Cell(printer, line, pos)).toMap
    for (line <- range; pos <- range; dx <- -1 to 1; dy <- -1 to 1 if dx != 0 || dy != 0) {
      (cells.get(line, pos), cells.get(line + dx, pos + dy)) match {
        case (Some(cell), Some(neighbor)) => cell.addNeighbor(neighbor)
        case _ => ()
      }
    }
  }
}

class Cell(printer: Printer, line: Int, pos: Int) extends Clock.Subscriber {
  private var status = false
  setStatus(Cell.random.nextBoolean)

  def isLive = status
  private def setStatus(status: Boolean) = {
    if (this.status != status) {
      ChangeCounter.countUp
      this.status = status
      printer.update(line, pos, if (isLive) "*" else " ")
    }
  }
  private def nextStatus = (isLive, neighborsLiveCount) match {
    case (false, 3) => true
    case (true, 2) => true
    case (true, 3) => true
    case _ => false
  }

  private var neighbors: Set[Cell] = Set.empty
  def addNeighbor(cell: Cell) = {
    neighbors += cell
  }

  private var neighborsLiveCount: Int = 0
  override def onEvent(event: Clock.Event) = event match {
    case Clock.Prepare => neighborsLiveCount = neighbors.count(_.isLive)
    case Clock.Update => setStatus(nextStatus)
    case _ => ()
  }
}

object Main {
  val size = 5

  def main(args: Array[String]) {
    Cell.createNetwork(new Printer(size), size)
    Clock.start
  }
}
