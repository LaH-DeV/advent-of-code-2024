import java.util.*;
import java.nio.file.*;
import java.io.IOException;

class Main {
	private static String filename = "input.txt";
	private static int[][] grid;
	private static IntPair[]directions = new IntPair[] {
		new IntPair(0, 1), // right
		new IntPair(0, -1), // left
		new IntPair(1, 0), // down
		new IntPair(-1, 0), // up
	};

	public static void main(String[] args) {
		grid = readGrid();
		if (grid == null) return;
		int gridX = grid.length;
		int gridY = grid[0].length;

		IntPair trails = new IntPair(0, 0);

		for (int row = 0; row < gridX; row++)
		for (int col = 0; col < gridY; col++) {
			if (grid[row][col] != 0) continue;
			IntPair start = new IntPair(row, col);
			trails.addTo(lookForTrails(start, gridX, gridY));
		}
		System.out.println("Total number of trails: " + trails.x);
		System.out.println("Total ratings of trails: " + trails.y);
	}

	public static IntPair lookForTrails(IntPair start, int gridX, int gridY) {
		Set<IntPair> trails = new HashSet<>();
		Queue<IntPair> queue = new ArrayDeque<>();

		queue.add(start);
		int trailsCount = 0;

		while (!queue.isEmpty()) {
			IntPair current = queue.poll();
			int currentValue = grid[current.x][current.y];
			if (currentValue == 9) {
				trails.add(current);
				trailsCount++;
				continue;
			}
			for (IntPair direction : directions) {
				IntPair next = current.add(direction);
				if (!inBounds(gridX, gridY, next)) continue;
				if (grid[next.x][next.y] != currentValue + 1) continue;
				queue.add(next);
			}
		}
		return new IntPair(trails.size(), trailsCount);
	}

	public static boolean inBounds(int maxX, int maxY, IntPair point) {
		return point.x >= 0 && point.x < maxX && point.y >= 0 && point.y < maxY;
	}

	public static int[][] readGrid() {
		Path path = Paths.get(filename);
		try {
			List<String> lines = Files.readAllLines(path);
			return lines.stream()
					.map(line -> line.chars().map(Character::getNumericValue).toArray())
					.toArray(int[][]::new);
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	}
}

class IntPair {
	int x;
	int y;
	IntPair(int x, int y) {
		this.x = x; this.y = y;
	}

	IntPair add(IntPair other) {
		return new IntPair(this.x + other.x, this.y + other.y);
	}

	void addTo(IntPair other) {
		this.x += other.x;
		this.y += other.y;
	}

	@Override // Override equals and hashCode for use in sets
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || !(o instanceof IntPair)) return false;
		IntPair intPair = (IntPair) o;
		return x == intPair.x && y == intPair.y;
	}

	@Override
	public int hashCode() {
		return Objects.hash(x, y);
	}
}
