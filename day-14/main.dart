import 'dart:io';
import 'dart:math';

const int GRID_WIDTH = 101;
const int GRID_HEIGHT = 103;

const int NUM_COMBINED_MOD = GRID_WIDTH * GRID_HEIGHT;
const int MIN_COLUMN_HEIGHT = 33;  // min for tree bounding box (x-coords)
const int MIN_ROW_HEIGHT = 31;     // min for tree bounding box (y-coords)

// multiplicative inverses for the Chinese Remainder Theorem
final Map<String, int> inverses = calculateInverses();
final int columnMultiplier = inverses['columnMultiplier']!;
final int rowMultiplier = inverses['rowMultiplier']!;

final RegExp numbersRegex = RegExp(r'-?\d+');

int mod(int a, int b) {
  // mod that always returns positive values
  return (a % b + b) % b;
}

List<List<int>> parseRobotNumbers(String input) {
    var numberify = (str) => 
        numbersRegex.allMatches(str)
        .map((match) => int.parse(match.group(0)!))
        .toList();
    return input.split('\n').map((str) => numberify(str)).toList();
}

int partOne(String input) {
  const int ITERATIONS = 100;
  bool inQuadrant(Robot r, Quadrant q) =>
      r.x >= q.xLeft && r.x <= q.xRight && r.y >= q.yTop && r.y <= q.yBot;

  List<Quadrant> quadrants = getQuadrants(GRID_WIDTH, GRID_HEIGHT);
  List<Robot> robots = parseRobotNumbers(input).map((numbers) {
    final int x = numbers[0];
    final int y = numbers[1];
    final int vx = numbers[2];
    final int vy = numbers[3];
    final int xn = mod((vx * ITERATIONS + x), GRID_WIDTH);
    final int yn = mod((vy * ITERATIONS + y), GRID_HEIGHT);
    return Robot(x: xn, y: yn);
  }).toList();

  List<int> inQuadrants = quadrants.map((q) {
    return robots.where((r) => inQuadrant(r, q)).length;
  }).toList();

  return inQuadrants.reduce((acc, e) => acc * e);
}

List<Quadrant> getQuadrants(int gridWidth, int gridHeight) {
  final int horizMidLeft = (gridWidth - 2) ~/ 2;
  final int horizMidRight = (gridWidth + 2) ~/ 2;
  final int vertMidTop = (gridHeight - 2) ~/ 2;
  final int vertMidBot = (gridHeight + 2) ~/ 2;

  return [
    Quadrant(xLeft: 0, yTop: 0, xRight: horizMidLeft, yBot: vertMidTop),
    Quadrant(xLeft: horizMidRight, yTop: 0, xRight: gridWidth - 1, yBot: vertMidTop),
    Quadrant(xLeft: 0, yTop: vertMidBot, xRight: horizMidLeft, yBot: gridHeight - 1),
    Quadrant(xLeft: horizMidRight, yTop: vertMidBot, xRight: gridWidth - 1, yBot: gridHeight - 1),
  ];
}

class Quadrant {
  final int xLeft, xRight, yTop, yBot;
  Quadrant({required this.xLeft, required this.xRight, required this.yTop, required this.yBot});
}

class Robot {
  final int x, y;
  Robot({required this.x, required this.y});
}

Map<String, int> extendedEuclidean(int a, int b) {
  int x0 = 1, x1 = 0;
  int y0 = 0, y1 = 1;

  while (b != 0) {
    int q = a ~/ b;
    int r = a % b;

    int tempX = x0 - q * x1;
    int tempY = y0 - q * y1;

    a = b;
    b = r;
    x0 = x1;
    x1 = tempX;
    y0 = y1;
    y1 = tempY;
  }

  return {'gcd': a, 'x': x0, 'y': y0};
}

Map<String, int> calculateInverses() {
  // inverse of GRID_HEIGHT mod GRID_WIDTH
  Map<String, int> columnInverse = extendedEuclidean(GRID_HEIGHT, GRID_WIDTH);
  if (columnInverse['gcd'] != 1) throw Exception('No inverse exists for GRID_HEIGHT modulo GRID_WIDTH');
  final int columnMultiplier = mod((columnInverse['x']! + GRID_WIDTH), GRID_WIDTH);

  // inverse of GRID_WIDTH mod GRID_HEIGHT
  Map<String, int> rowInverse = extendedEuclidean(GRID_WIDTH, GRID_HEIGHT);
  if (rowInverse['gcd'] != 1) throw Exception('No inverse exists for GRID_WIDTH modulo GRID_HEIGHT');
  final int rowMultiplier = mod((rowInverse['x']! + GRID_HEIGHT), GRID_HEIGHT);

  final int scaledColumnMultiplier = mod((columnMultiplier * GRID_HEIGHT), NUM_COMBINED_MOD);
  final int scaledRowMultiplier = mod((rowMultiplier * GRID_WIDTH), NUM_COMBINED_MOD);

  return {'columnMultiplier': scaledColumnMultiplier, 'rowMultiplier': scaledRowMultiplier};
}

int partTwo(String input) {
  List<List<int>> robots = parseRobotNumbers(input);

  // Searching for times mod GRID_WIDTH when the tree could possibly exist using x coors only.
  List<int> columns = [];
  for (int time = 0; time < GRID_WIDTH; time++) {
    List<int> xCounts = List.filled(GRID_WIDTH, 0);
    for (var robot in robots) { // [x, y, vx, vy]
      int index = mod(robot[0] + robot[2] * time, GRID_WIDTH);
      xCounts[index]++;
    }
    if (xCounts.where((c) => c >= MIN_COLUMN_HEIGHT).length >= 2) {
      columns.add(time);
    }
  }

  // Searching for times mod GRID_HEIGHT when the tree could possibly exist using y coors only.
  List<int> rows = [];
  for (int time = 0; time < GRID_HEIGHT; time++) {
    List<int> yCounts = List.filled(GRID_HEIGHT, 0);
    for (var robot in robots) { // [x, y, vx, vy]
      int index = mod(robot[1] + robot[3] * time, GRID_HEIGHT);
      yCounts[index]++;
    }
    if (yCounts.where((c) => c >= MIN_ROW_HEIGHT).length >= 2) {
      rows.add(time);
    }
  }

  // If there's only one combination then return answer.
  if (rows.length == 1 && columns.length == 1) {
    int columnTime = columns[0];
    int rowTime = rows[0];
    return mod(columnMultiplier * columnTime + rowMultiplier * rowTime, NUM_COMBINED_MOD);
  }

  // Backup check for time when all robot positions are unique.
  Map<Point<int>, int> grid = {};
  for (int columnTime in columns) {
    for (int rowTime in rows) {
      int time = mod(columnMultiplier * columnTime + rowMultiplier * rowTime, NUM_COMBINED_MOD);

      bool valid = true;
      for (var robot in robots) { // [x, y, vx, vy]
        int x = mod(robot[0] + robot[2] * time, GRID_WIDTH);
        int y = mod(robot[1] + robot[3] * time, GRID_HEIGHT);
        
        Point<int> point = Point(x, y);
        if (grid.containsKey(point) && grid[point] == time) {
          // Continue to next robot if point is occupied at the same time
          continue;
        }

        // If any point has a collision, the current combination is invalid
        grid[point] = time;
        valid = false;
        break;
      }

      if (valid) {
        return time;
      }
    }
  }

  throw Exception("No solution.");
}

void main() async {
  String input = await File("input.txt").readAsString();
  print(partOne(input));
  print(partTwo(input));
}
