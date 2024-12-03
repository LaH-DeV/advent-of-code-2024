#include <stdio.h>

#define FILENAME "input.txt"
#define FILE_SIZE 19979 // the size of the file is known

int parse_number(char buff[], int* ptr) {
	int num = 0;
	while (buff[*ptr] != '\0' && (buff[*ptr] >= '0' && buff[*ptr] <= '9')) {
		num = num * 10 + (buff[*ptr] - '0');
		(*ptr)++;
	}
	return num;
}

int chop(char buff[], int* ptr, char str[]) {
	int i = 0;
	while (str[i] != '\0') {
		if (buff[*ptr + i] != str[i]) return 0;
		i++;
	}
	(*ptr) += i;
	return 1;
}

void check_flag(char s[], int* i, int* do_flag) {
	if (chop(s, i, "do()")) {
		(*do_flag) = 1;
	} else if (chop(s, i, "don't()")) {
		(*do_flag) = 0;
	}
}

int parse_mul(char buff[], int *ptr, int *do_flag) {
	while (*ptr < FILE_SIZE && !chop(buff, ptr, "mul(")) {
		if (do_flag != NULL) check_flag(buff, ptr, do_flag);
		if (chop(buff, ptr, "mul(")) break;
		(*ptr)++;
	}
	int a = parse_number(buff, ptr);
	if (!chop(buff, ptr, ",")) return 0;
	int b = parse_number(buff, ptr);
	if (!chop(buff, ptr, ")")) return 0;
	return a * b;
}

void part_one(char buffer[]) {
	int sum = 0;
	int i = 0;
	while (i < FILE_SIZE) {
		sum += parse_mul(buffer, &i, NULL);
	}
	printf("Part1 :: Sum: %d\n", sum);
}

void part_two(char buffer[]) {
	int sum = 0;
	int do_flag = 1;
	int i = 0;
	while (i < FILE_SIZE) {
		int m = parse_mul(buffer, &i, &do_flag);
		if (do_flag) sum += m;
	}
	printf("Part2 :: Sum: %d\n", sum);
}

int main() {
	FILE *file = fopen(FILENAME, "r");
	if (file == NULL) {
		printf("Error opening file \"%s\"\n", FILENAME);
		return 1;
	}

	char buffer[FILE_SIZE];
	size_t bytes_read = fread(buffer, 1, FILE_SIZE, file);
	if (bytes_read == 0) {
		printf("Error reading the file or file is empty.\n");
		fclose(file);
		return 1;
	}
	buffer[bytes_read] = '\0';

	part_one(buffer);
	part_two(buffer);

	fclose(file);
	return 0;
}