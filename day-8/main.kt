import java.io.File

data class Vec2(val x: Int, val y: Int) {
    operator fun minus(other: Vec2) = Vec2(this.x - other.x, this.y - other.y)
    operator fun plus(other: Vec2) = Vec2(this.x + other.x, this.y + other.y)
    operator fun times(scalar: Int) = Vec2(this.x * scalar, this.y * scalar)
} 

fun partOne(antennas: Map<Char, MutableSet<Vec2>>, inBounds: (Vec2) -> Boolean): Int {
    val antinodeLocations = mutableSetOf<Vec2>()

    for (antenna in antennas.keys)
    for (v1 in antennas[antenna]!!)
    for (v2 in antennas[antenna]!!) {
        if (v1 == v2) continue
        val antinode = v1 + ((v2 - v1) * 2)
        if (inBounds(antinode)) {
            antinodeLocations.add(antinode)
        }
    }

    return antinodeLocations.size
}

fun partTwo(antennas: Map<Char, MutableSet<Vec2>>, inBounds: (Vec2) -> Boolean): Int {
    val antinodeLocations = mutableSetOf<Vec2>()

    for (antenna in antennas.keys)
    for (v1 in antennas[antenna]!!)
    for (v2 in antennas[antenna]!!) {
        if (v1 == v2) continue
        var positiveNextLocation = v1
        var negativeNextLocation = v1
        val distance = v2 - v1
        do {
            positiveNextLocation = positiveNextLocation + distance
            negativeNextLocation = negativeNextLocation - distance
            if (inBounds(negativeNextLocation)) {
                antinodeLocations.add(negativeNextLocation)
            }
            if (inBounds(positiveNextLocation)) {
                antinodeLocations.add(positiveNextLocation)
            }
        } while (inBounds(positiveNextLocation))
    }

    return antinodeLocations.size
}

fun main() {
    val lines = File("input.txt").readLines()
    val gridYRange = lines.indices
    val gridXRange = lines[0].indices
    val grid = lines.map { line -> line }
    val antennaPositions = mutableMapOf<Char, MutableSet<Vec2>>()

    for (rowIndex in grid.indices)
    for (colIndex in grid[0].indices) {
        val cell = grid[rowIndex][colIndex]
        if (cell == '.') continue;
        antennaPositions.computeIfAbsent(cell) { mutableSetOf() }
        .add(Vec2(rowIndex, colIndex))
    }

    val inBounds = { vec: Vec2 -> vec.x in gridXRange && vec.y in gridYRange }

    val antinodes1 = partOne(antennaPositions, inBounds)
    val antinodes2 = partTwo(antennaPositions, inBounds)

    println(antinodes1)
    println(antinodes2)
}