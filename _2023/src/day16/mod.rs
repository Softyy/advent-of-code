use std::{collections::HashSet, fs};

#[derive(Debug, Hash, PartialEq, Eq, Clone)]

struct Point {
    x: usize,
    y: usize,
}

impl Point {
    fn next(&self, dir: Direction, max_x: usize, max_y: usize) -> Option<Point> {
        match dir {
            Direction::North => {
                let next_y = self.y.saturating_sub(1);
                if next_y == self.y {
                    return None;
                }
                return Some(Point {
                    x: self.x,
                    y: next_y,
                });
            }
            Direction::South => {
                let next_y = self.y + 1;
                if next_y >= max_y {
                    return None;
                }
                return Some(Point {
                    x: self.x,
                    y: next_y,
                });
            }
            Direction::East => {
                let next_x: usize = self.x + 1;
                if next_x >= max_x {
                    return None;
                }
                return Some(Point {
                    x: next_x,
                    y: self.y,
                });
            }
            Direction::West => {
                let next_x: usize = self.x.saturating_sub(1);
                if next_x == self.x {
                    return None;
                }
                return Some(Point {
                    x: next_x,
                    y: self.y,
                });
            }
        }
    }
}
#[derive(Debug, Hash, PartialEq, Eq, Clone, Copy)]

enum Direction {
    North,
    East,
    South,
    West,
}

fn go_go_beam(
    point: Point,
    dir: Direction,
    grid: &Vec<Vec<char>>,
    energized_gird: &mut Vec<Vec<u16>>,
    beams_seen: &mut HashSet<(Point, Direction)>,
) {
    if beams_seen.contains(&(point.clone(), dir)) {
        return;
    } else {
        beams_seen.insert((point.clone(), dir));
    }
    let max_x = grid[0].len();
    let max_y: usize = grid.len();
    energized_gird[point.y][point.x] += 1;

    match (grid[point.y][point.x], dir) {
        ('.', _)
        | ('|', Direction::North)
        | ('|', Direction::South)
        | ('-', Direction::East)
        | ('-', Direction::West) => {
            // continue direction
            if let Some(next_point) = point.next(dir, max_x, max_y) {
                go_go_beam(next_point, dir, grid, energized_gird, beams_seen)
            }
        }
        ('|', Direction::East) | ('|', Direction::West) => {
            // split
            if let Some(next_point) = point.next(Direction::North, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::North,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
            if let Some(next_point) = point.next(Direction::South, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::South,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('-', Direction::North) | ('-', Direction::South) => {
            // split
            if let Some(next_point) = point.next(Direction::East, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::East,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
            if let Some(next_point) = point.next(Direction::West, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::West,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('/', Direction::East) => {
            // reflect
            if let Some(next_point) = point.next(Direction::North, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::North,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('/', Direction::South) => {
            // reflect
            if let Some(next_point) = point.next(Direction::West, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::West,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('/', Direction::North) => {
            // reflect
            if let Some(next_point) = point.next(Direction::East, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::East,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('/', Direction::West) => {
            // reflect
            if let Some(next_point) = point.next(Direction::South, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::South,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('\\', Direction::South) => {
            // reflect
            if let Some(next_point) = point.next(Direction::East, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::East,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('\\', Direction::North) => {
            // reflect
            if let Some(next_point) = point.next(Direction::West, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::West,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('\\', Direction::East) => {
            // reflect
            if let Some(next_point) = point.next(Direction::South, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::South,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        ('\\', Direction::West) => {
            // reflect
            if let Some(next_point) = point.next(Direction::North, max_x, max_y) {
                go_go_beam(
                    next_point,
                    Direction::North,
                    grid,
                    energized_gird,
                    beams_seen,
                )
            }
        }
        _ => unreachable!(),
    }
}

fn count_grid(grid: &Vec<Vec<u16>>) -> u32 {
    let mut count = 0;

    for row in grid {
        for cell in row {
            count += if *cell > 0 { 1 } else { 0 };
        }
    }
    return count;
}

fn start_from(p: Point, dir: Direction, grid: &Vec<Vec<char>>) -> u32 {
    let mut energized_gird: Vec<Vec<u16>> = vec![vec![0; grid[0].len()]; grid.len()];
    let mut beams_seen: HashSet<(Point, Direction)> = HashSet::new();

    go_go_beam(p, dir, &grid, &mut energized_gird, &mut beams_seen);

    return count_grid(&energized_gird);
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day16/input.txt").expect("Should have been able to read the file");

    let grid: Vec<Vec<char>> = contents
        .lines()
        .map(|l| l.chars().collect::<Vec<char>>())
        .collect();

    println!(
        "{:?}",
        start_from(Point { x: 0, y: 0 }, Direction::East, &grid)
    ); // part 1: 6795

    let mut energized_tiles_count: Vec<u32> = Vec::new();

    for i in 0..grid.len() {
        let count_left = start_from(Point { x: 0, y: i }, Direction::East, &grid);
        energized_tiles_count.push(count_left);
        let count_right: u32 = start_from(
            Point {
                x: grid[0].len() - 1,
                y: i,
            },
            Direction::West,
            &grid,
        );
        energized_tiles_count.push(count_right);
    }

    for j in 0..grid[0].len() {
        let count_top = start_from(Point { x: j, y: 0 }, Direction::South, &grid);
        energized_tiles_count.push(count_top);
        let count_bottom: u32 = start_from(
            Point {
                x: j,
                y: grid.len() - 1,
            },
            Direction::North,
            &grid,
        );
        energized_tiles_count.push(count_bottom);
    }

    println!("{:?}", energized_tiles_count.iter().max());
}
