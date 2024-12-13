import os
import regex

fn extract_numbers_from_string(input string) ![]i64 {
    mut numbers := []i64{}
    mut re := regex.regex_opt(r'\d+')!
    
    for m in re.find_all_str(input) {
        num := m.i64()
        numbers << num
    }

    return numbers
}

fn prepare_data(content string) ![][]i64 {
    games := content.split("\r\n\r\n")
    mut data := [][]i64{}
    for game in games {
        mut nums := []i64{}
        for line in game.split_into_lines() {
            if line.trim_space() != "" {
                point := extract_numbers_from_string(line)!
                nums << point[0]
                nums << point[1]
            }
        }
        data << nums
    }
    return data
}

fn part_one(ax i64, ay i64, bx i64, by i64, px i64, py i64, max i64) i64 {
	a_count := (px * by - py * bx) / (ax * by - ay * bx)
	b_count := (px - ax * a_count) / bx
	if a_count > max || b_count > max {
		return 0
	}
	if ((px * by - py * bx) % (ax * by - ay * bx) != 0) || ((px - ax * a_count) % bx != 0) {
		return 0
	}
	return a_count * 3 + b_count
}

fn part_two(ax i64, ay i64, bx i64, by i64, px i64, py i64) i64 {
	a_count := i64((px * by - py * bx) / (ax * by - ay * bx))
	b_count := i64((px - ax * a_count) / bx)
	if ((px * by - py * bx) % (ax * by - ay * bx) != 0) || ((px - ax * a_count) % bx != 0) {
		return 0
	}
	return i64(a_count * 3 + b_count)
}

fn main() {
    file_path := 'input.txt'
    magic := i64(10000000000000)
    magic_max := 100
    content := os.read_file(file_path) or {
        eprintln('Failed to read file: $file_path')
        return
    }
    games := prepare_data(content)!

    mut score_one := i64(0)
    for game in games {
        score_one += part_one(game[0], game[1], game[2], game[3], game[4], game[5], magic_max)
    }
    mut score_two := i64(0)
    for game in games {
        score_two += part_two(game[0], game[1], game[2], game[3], game[4] + magic, game[5] + magic)
    }
    println(score_one) // 33427
    println(score_two) // 91649162972270
}
