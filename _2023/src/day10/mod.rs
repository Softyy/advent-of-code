use std::{char, fs};

#[derive(Debug, PartialEq)]
enum Direction {
    Left,
    Right,
    Down,
    Up,
    Nowhere,
}

fn goes_up(c: Option<char>) -> bool {
    match c {
        Some('|') => true,
        Some('L') => true,
        Some('J') => true,
        _ => false,
    }
}

fn goes_down(c: Option<char>) -> bool {
    match c {
        Some('|') => true,
        Some('F') => true,
        Some('7') => true,
        _ => false,
    }
}

fn goes_left(c: Option<char>) -> bool {
    match c {
        Some('-') => true,
        Some('7') => true,
        Some('J') => true,
        _ => false,
    }
}

fn goes_right(c: Option<char>) -> bool {
    match c {
        Some('-') => true,
        Some('F') => true,
        Some('L') => true,
        _ => false,
    }
}

#[derive(Debug, Clone, PartialEq)]
struct Point {
    x: usize,
    y: usize,
}

impl Point {
    fn left(&self) -> Point {
        Point {
            x: self.x.saturating_sub(1),
            y: self.y,
        }
    }

    fn up(&self) -> Point {
        Point {
            x: self.x,
            y: self.y.saturating_sub(1),
        }
    }

    fn right(&self) -> Point {
        Point {
            x: self.x.saturating_add(1),
            y: self.y,
        }
    }

    fn down(&self) -> Point {
        Point {
            x: self.x,
            y: self.y.saturating_add(1),
        }
    }

    fn calc_direction(&self, other: Option<Point>) -> Direction {
        if other.is_none() {
            return Direction::Nowhere;
        }
        let other_unwrapped = other.unwrap();
        match (
            (self.x as isize - other_unwrapped.x as isize),
            (self.y as isize - other_unwrapped.y as isize),
        ) {
            (0, -1) => Direction::Down,
            (0, 1) => Direction::Up,
            (-1, 0) => Direction::Right,
            (1, 0) => Direction::Left,
            _ => Direction::Nowhere,
        }
    }
}

#[derive(Debug, Clone)]
struct Grid {
    map: Vec<Vec<char>>,
    start: Point,
}

impl Grid {
    fn get(&self, point: Point) -> Option<char> {
        if let Some(row) = self.map.get(point.y) {
            return row.get(point.x).copied();
        }
        return None;
    }

    fn can_go_up(&self, point: &Point) -> bool {
        let up = point.up();
        if up == *point {
            return false;
        }
        return goes_up(self.get(point.clone())) && goes_down(self.get(up));
    }

    fn can_go_down(&self, point: &Point) -> bool {
        let down = point.down();
        if down == *point {
            return false;
        }
        return goes_down(self.get(point.clone())) && goes_up(self.get(down));
    }

    fn can_go_left(&self, point: &Point) -> bool {
        let left = point.left();
        if left == *point {
            return false;
        }
        return goes_left(self.get(point.clone())) && goes_right(self.get(left));
    }

    fn can_go_right(&self, point: &Point) -> bool {
        let right = point.right();
        if right == *point {
            return false;
        }
        return goes_right(self.get(point.clone())) && goes_left(self.get(right));
    }

    fn replace_start_symbol(&mut self) {
        let start_symbol = match (
            goes_right(self.get(self.start.left())),
            goes_left(self.get(self.start.right())),
            goes_up(self.get(self.start.down())),
            goes_down(self.get(self.start.up())),
        ) {
            (true, true, false, false) => '-',
            (true, false, true, false) => 'L',
            (true, false, false, true) => 'J',
            (false, true, true, false) => 'F',
            (false, true, false, true) => '7',
            (false, false, true, true) => '|',
            _ => panic!("this isn't right"),
        };
        println!("{}", start_symbol);
        self.map[self.start.y][self.start.x] = start_symbol;
    }

    fn traverse_loop(&self, pos: Point, last_pos: Option<Point>) -> usize {
        if last_pos.is_some() && pos == self.start {
            return 1;
        }

        let cant_go = pos.calc_direction(last_pos);

        if self.can_go_down(&pos) && cant_go != Direction::Down {
            return self.traverse_loop(pos.down(), Some(pos)) + 1;
        } else if self.can_go_left(&pos) && cant_go != Direction::Left {
            return self.traverse_loop(pos.left(), Some(pos)) + 1;
        } else if self.can_go_up(&pos) && cant_go != Direction::Up {
            return self.traverse_loop(pos.up(), Some(pos)) + 1;
        } else if self.can_go_right(&pos) && cant_go != Direction::Right {
            return self.traverse_loop(pos.right(), Some(pos)) + 1;
        } else {
            panic!("We've got nowhere else to go");
        }
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day10/input.txt").expect("Should have been able to read the file");

    let map: Vec<Vec<char>> = contents.lines().map(|l| l.chars().collect()).collect();

    let mut start: Point = Point { x: 0, y: 0 };
    for y in 0..map.len() {
        if let Some(x) = map[y].iter().position(|&x| x == 'S') {
            start = Point { x, y };
            break;
        }
    }

    let mut grid = Grid {
        map,
        start: start.clone(),
    };

    grid.replace_start_symbol();

    let loop_length: usize = grid.traverse_loop(start, None);

    println!("{:?}", loop_length / 2); // 6806

    // part 2
}
