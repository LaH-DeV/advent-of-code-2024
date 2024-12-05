#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

bool grid_lookup(const vector<string>& grid, int row, int col, const string& target, const pair<int, int>& direction) {
	for (int i = 0; i < target.length(); i++) {
		int new_row = row + i * direction.first;
		int new_col = col + i * direction.second;
		if (new_row < 0 || new_row >= grid.size()) return false;
		if (new_col < 0 || new_col >= grid[0].size()) return false;
		if (grid[new_row][new_col] != target[i]) return false;
	}
	return true;
}

int part_one(const vector<string>& grid) {
	const string target = "XMAS";
	vector<pair<int, int>> directions = {
		{0, 1}, {1, 0}, {1, 1}, {1, -1}
	};
	int count = 0;
	for (int row = 0; row < grid.size(); row++)
	for (int col = 0; col < grid[0].size(); col++)
	for (const auto& direction : directions) {
		if (grid_lookup(grid, row, col, target, direction)) {
			count++;
		}
		const auto& rev_dir = make_pair(-direction.first, -direction.second);
		if (grid_lookup(grid, row, col, target, rev_dir)) {
			count++;
		}
	}
	return count;
}

int part_two(const vector<string>& grid) {
	int count = 0;
	vector<pair<int, int>> directions = { {-1, -1}, {1, 1} };
	for (int row = 1; row < grid.size() - 1; row++)
	for (int col = 1; col < grid[0].size() - 1; col++){
		if (grid[row][col] != 'A') continue;
		// |a|   |b|
		// | |'A'| |
		// |c|   |d|
		char a = grid[row - 1][col - 1];
		char b = grid[row + 1][col + 1];
		char c = grid[row + 1][col - 1];
		char d = grid[row - 1][col + 1];
		if (
			(a == 'M' && b == 'S' || a == 'S' && b == 'M')
		 && (c == 'M' && d == 'S' || c == 'S' && d == 'M')
		) count++;
	}
	return count;
}

int main() {
	ifstream input_file("input.txt");
	if (!input_file) {
		cerr << "Error: Could not open the file 'input.txt'" << endl;
		return 1;
	}

	vector<string> grid;
	string line;

	while (getline(input_file, line)) {
		grid.push_back(line);
	}

	input_file.close();

	cout << "Part one: " << part_one(grid) << endl;
	cout << "Part two: " << part_two(grid) << endl;

	return 0;
}
