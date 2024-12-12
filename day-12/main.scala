//> using scala 3.6.2
import collection.mutable.{Set, ListBuffer, Queue}

type Grid[T] = Array[Array[T]]

case class Point(x: Int, y: Int) {
  def +(other: Point): Point = Point(x + other.x, y + other.y)
  def -(other: Point): Point = Point(x - other.x, y - other.y)
  def mix(other: Point): Point = Point(x + other.y, y + other.x)
  def inRange(n: Int, m: Int): Boolean = x >= 0 && x < n && y >= 0 && y < m
  override def equals(other: Any): Boolean = other match
    case that: Point => x == that.x && y == that.y
    case _ => false
  override def hashCode(): Int = x.hashCode() * 31 + y.hashCode()
  override def toString: String = s"($x, $y)" 
}

class Garden(grid: Grid[Char]) {
  val n = grid.length
  val m = grid(0).length
  val visited = Array.ofDim[Boolean](n, m)
  val DIRECTIONS = List(Point(1, 0), Point(0, 1), Point(0, -1), Point(-1, 0))

  def calculateFencePrice(sides: Boolean = false): Int = {
    var res = 0
    for row <- 0 until n
        col <- 0 until m do
      if !visited(row)(col) then
        val (area, perimeter) = bfsRegion(Point(row, col))
        if sides then
          res += area.size * countRegionSides(area)
        else
          res += area.size * perimeter
    res
  }

  def bfsRegion(pos: Point): (Set[Point], Int) =
    val area = Set[Point]()
    var perimeter = 0
    val queue = Queue[Point]()
    queue.enqueue(pos)
    visited(pos.x)(pos.y) = true
    while queue.nonEmpty do
        val curr = queue.dequeue()
        area.add(curr)
        val neighbors = getNeighborsInRegion(curr)
        perimeter += 4 - neighbors.length
        for neighbor <- neighbors do
          if !visited(neighbor.x)(neighbor.y) then
            queue.enqueue(neighbor)
            visited(neighbor.x)(neighbor.y) = true
    (area, perimeter)

  def getNeighborsInRegion(pos: Point): List[Point] =
    val plant = grid(pos.x)(pos.y)
    val neighbors = ListBuffer[Point]()
    for direction <- DIRECTIONS do
      val point = pos + direction
      if point.inRange(n, m) && grid(point.x)(point.y) == plant then
        neighbors.append(point)
    neighbors.toList

  def countRegionSides(region: Set[Point]): Int =
    var sideCount = 0
    for direction <- DIRECTIONS do
      val sides = Set[Point]()
      for pos <- region do
        val tmp = pos + direction;
        if !region.contains(tmp) then
          sides.add(tmp)
      val remove = Set[Point]()
      for side <- sides do
        var tmp = side.mix(direction)
        while sides.contains(tmp) do
          remove.add(tmp);
          tmp = tmp.mix(direction)
      sideCount += sides.size - remove.size
    sideCount
}

def parseGardenGrid(filename: String): Grid[Char] =
  val source = scala.io.Source.fromFile(filename)
  try source.getLines().toList.map(_.toCharArray).toArray finally source.close()


def partOne(filename: String): Int =
  val garden = Garden(parseGardenGrid(filename))
  return garden.calculateFencePrice()

def partTwo(filename: String): Int =
  val garden = Garden(parseGardenGrid(filename))
  return garden.calculateFencePrice(true)


@main
def main(): Unit =
  assert(partOne("input.txt") == 1573474)
  assert(partTwo("input.txt") == 966476)