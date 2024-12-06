use fxhash::FxHashSet as HashSet;
use rayon::prelude::*;
use std::fs;

pub fn parse_input(input: &str) -> Option<(Vec<Vec<bool>>, Position)> {
    let mut starting_pos = Position { x: 0, y: 0 };
    // world map is a 2D vector of booleans (true = obstacle, false = empty space)
    let lab_map: Option<Vec<Vec<bool>>> = match fs::read_to_string(input) {
        Ok(contents) => Some(
            contents
                .lines()
                .enumerate()
                .map(|(row, line)| {
                    line.chars()
                        .enumerate()
                        .map(|(col, ch)| match ch {
                            '#' => true,
                            '^' => {
                                starting_pos.x = col as isize;
                                starting_pos.y = row as isize;
                                false
                            }
                            _ => false,
                        })
                        .collect::<Vec<bool>>()
                })
                .collect::<Vec<Vec<bool>>>(),
        ),
        Err(_e) => None,
    };
    lab_map.map(|lab_map| (lab_map, starting_pos))
}

pub fn part_one(lab_map: &Vec<Vec<bool>>, starting_pos: Position) -> usize {
    let lab = Lab::new(lab_map.len(), lab_map[0].len(), flatten_lab_map(lab_map));
    let mut guard = Guard::new(starting_pos, Direction::N);

    count_visited_places(&lab, &mut guard)
}

pub fn part_two(lab_map: &Vec<Vec<bool>>, starting_pos: Position) -> usize {
    let lab = Lab::new(lab_map.len(), lab_map[0].len(), flatten_lab_map(lab_map));
    let guard = Guard::new(starting_pos, Direction::N);

    count_infinite_loop_ways(&lab, &guard)
}

fn flatten_lab_map(map: &Vec<Vec<bool>>) -> Vec<bool> {
    map.iter().flatten().cloned().collect()
}

fn count_visited_places(lab: &Lab, guard: &mut Guard) -> usize {
    let mut visited = HashSet::default();
    visited.insert(guard.pos);

    while !lab.out_of_bounds(guard.pos) {
        if lab.at_obstacle(guard.step(false)) {
            guard.turn_right();
        }
        visited.insert(guard.step(true));
    }
    visited.len() - 1
}

fn count_infinite_loop_ways(lab: &Lab, guard: &Guard) -> usize {
    (0..lab.width)
        .into_par_iter()
        .map(|x| {
            let mut new_lab = lab.clone();
            (0..lab.height)
                .filter(|y| guard.loops_at(x, *y, &mut new_lab))
                .count()
        })
        .sum()
}

#[derive(Clone)]
struct Lab {
    vector: Vec<bool>,
    height: usize,
    width: usize,
}

impl Lab {
    fn new(height: usize, width: usize, vector: Vec<bool>) -> Self {
        Self {
            vector,
            height,
            width,
        }
    }

    fn out_of_bounds(&self, pos: Position) -> bool {
        return pos.x < 0
            || pos.y < 0
            || pos.x >= self.width as isize
            || pos.y >= self.height as isize;
    }

    fn at_obstacle(&self, pos: Position) -> bool {
        if self.out_of_bounds(pos) {
            return false;
        }
        self.vector[pos.y as usize * self.height + pos.x as usize]
    }

    fn move_obstacle(&mut self, pos: Position, obstacle: bool) {
        self.vector[pos.y as usize * self.height + pos.x as usize] = obstacle;
    }
}

#[derive(Clone, Copy, Eq, PartialEq, Hash)]
struct Guard {
    pos: Position,
    dir: Direction,
}

impl Guard {
    pub fn new(pos: Position, dir: Direction) -> Self {
        Self { pos, dir }
    }

    fn point(&self) -> (Position, Direction) {
        (self.pos, self.dir)
    }

    fn step(&mut self, commit: bool) -> Position {
        let pos = self.dir.next_step_position(self.pos);
        if commit {
            self.pos = pos;
        }
        pos
    }

    fn turn_right(&mut self) {
        self.dir.next_direction();
    }

    fn loops_at(&self, x: usize, y: usize, lab: &mut Lab) -> bool {
        let new_pos = Position {
            x: x as isize,
            y: y as isize,
        };

        if self.pos == new_pos || lab.at_obstacle(new_pos) {
            return false;
        }

        lab.move_obstacle(new_pos, true);
        let is_cycle = self.in_cycle(lab);
        lab.move_obstacle(new_pos, false);
        is_cycle
    }

    fn in_cycle(mut self, lab: &Lab) -> bool {
        let mut visited = HashSet::default();
        visited.insert(self.point());

        while !lab.out_of_bounds(self.pos) {
            while lab.at_obstacle(self.step(false)) {
                self.turn_right();
            }
            self.step(true);
            if !visited.insert(self.point()) {
                return true;
            }
        }
        false
    }
}

#[derive(Clone, Copy, Eq, PartialEq, Hash)]
pub struct Position {
    pub x: isize,
    pub y: isize,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
enum Direction {
    N,
    S,
    E,
    W,
}

impl Direction {
    fn next_direction(&mut self) {
        *self = match self {
            Direction::N => Direction::W,
            Direction::S => Direction::E,
            Direction::E => Direction::N,
            Direction::W => Direction::S,
        }
    }

    fn next_step_position(&self, mut pos: Position) -> Position {
        match self {
            Direction::N => pos.y -= 1,
            Direction::S => pos.y += 1,
            Direction::E => pos.x -= 1,
            Direction::W => pos.x += 1,
        }
        pos
    }
}
