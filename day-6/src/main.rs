fn main() {
    let filename = "input.txt";
    if let Some((lab_map, starting_pos)) = aoc6::parse_input(filename) {
        let r1 = aoc6::part_one(&lab_map, starting_pos);
        let r2 = aoc6::part_two(&lab_map, starting_pos);
        println!("Part one: {}", r1); // part 1 = 5516
        println!("Part two: {}", r2); // part 2 = 2008
    } else {
        println!("Error parsing input");
    }
}
