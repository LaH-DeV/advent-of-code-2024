def part_one(disk):
	get_id = lambda i: i // 2 if i % 2 == 0 else -1
	disk = [get_id(i) for i, size in enumerate(disk) for _ in range(size)]
	left_ptr = 0
	right_ptr = len(disk) - 1
	while left_ptr < right_ptr:
		if disk[right_ptr] == -1:
			right_ptr -= 1
			continue
		if disk[left_ptr] != -1:
			left_ptr += 1
			continue
		disk[left_ptr] = disk[right_ptr]
		disk[right_ptr] = -1
		left_ptr += 1
		right_ptr -= 1
	return sum(position * file_id for position, file_id in enumerate(disk) if file_id != -1)

def part_two(disk):
	files = []
	free_spaces = []
	curr_idx = 0
	for i, size in enumerate(disk):
		if i % 2 == 0:
			files.append((i // 2, size, curr_idx))
		elif size > 0:
			free_spaces.append((size, curr_idx))
		curr_idx += size

	moved_files = []
	for file_id, size, position in reversed(files):
		for i, (gap_size, free_space) in enumerate(free_spaces):
			if free_space > position:
				moved_files.append((file_id, size, position))
				break
			if gap_size < size:
				continue
			moved_files.append((file_id, size, free_space))
			free_spaces[i] = (gap_size - size, free_space + size)
			break
		else:
			moved_files.append((file_id, size, position))

	calculate_progression = lambda file_id, size, position: file_id * (position * size + size * (size - 1) // 2)
	return sum(calculate_progression(file_id, size, pos) for file_id, size, pos in moved_files)

def main(filename):
	file_content = open(filename, "r").read()
	disk = list(map(int, file_content))

	print(part_one(disk))
	print(part_two(disk))


if __name__ == "__main__":
	main("input.txt")
