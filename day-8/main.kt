import java.io.File

data class Vec2(val x: Int, val y: Int) {
    operator fun minus(other: Vec2) = Vec2(this.x - other.x, this.y - other.y)
    operator fun plus(other: Vec2) = Vec2(this.x + other.x, this.y + other.y)
    operator fun times(scalar: Int) = Vec2(this.x * scalar, this.y * scalar)
} 

fun main() {
    val lines = File("input.txt").readLines()
    val antennas = mutableMapOf<Char, MutableSet<Vec2>>()

    for (row in lines.indices)
    for (col in lines[0].indices) {
        val cell = lines[row][col]
        if (cell == '.') continue;
        antennas.computeIfAbsent(cell) { mutableSetOf() }
                .add(Vec2(row, col))
    }

    val linesYRange = lines.indices
    val linesXRange = lines[0].indices
    val inBounds = { vec: Vec2 -> vec.x in linesXRange && vec.y in linesYRange }

    val antinodes1 = mutableSetOf<Vec2>() // part one
    val antinodes2 = mutableSetOf<Vec2>() // part two

 	for (antenna in antennas.keys)
    for (v1 in antennas[antenna]!!)
    for (v2 in antennas[antenna]!!) {
        if (v1 == v2) continue
        val distance = v2 - v1
     	// relative distance from doubled distance
        val antinode = v1 + (distance * 2) 
        if (inBounds(antinode)) {
            antinodes1.add(antinode)
        }
        var positiveNextLocation = v1
        var negativeNextLocation = v1
        do {
            positiveNextLocation = positiveNextLocation + distance
            negativeNextLocation = negativeNextLocation - distance
            if (inBounds(negativeNextLocation)) {
                antinodes2.add(negativeNextLocation)
            }
            if (inBounds(positiveNextLocation)) {
                antinodes2.add(positiveNextLocation)
            }
        } while (inBounds(positiveNextLocation))
    }

    println(antinodes1.size)
    println(antinodes2.size)
}