use std::fs;

#[derive(Debug, Clone, PartialEq, Eq)]

enum Direction {
    North,
    East,
    South,
    West,
}

#[derive(Debug, Clone)]
struct BlockRecord {
    value: u32,
    last_moves: Vec<Direction>,
}

impl BlockRecord {
    fn new(value: u32) -> Self {
        Self {
            value,
            last_moves: Vec::new(),
        }
    }

    fn can_go(&self, dir: Direction) -> bool {
        return self.last_moves.len() < 3 || self.last_moves.iter().all(|m| m != &dir);
    }
}

fn explore(
    row: usize,
    col: usize,
    min: u32,
    grid: &Vec<Vec<u32>>,
    score_grid: &mut Vec<Vec<BlockRecord>>,
) {
    let mut score = &score_grid[row][col];
    if score.value > min {
        // update the score for the block
        score.value = min;
    } else {
        // this is not the way
        return;
    }

    if row > 0 && score.can_go(Direction::North) {
        let heat_loss = grid[row - 1][col];
        explore(row - 1, col, min + heat_loss, grid, score_grid);
    }

    if row < grid.len() - 1 && score.can_go(Direction::South) {
        let heat_loss = grid[row + 1][col];
        explore(row + 1, col, min + heat_loss, grid, score_grid);
    }

    if col > 0 && score.can_go(Direction::West) {
        let heat_loss = grid[row][col - 1];
        explore(row, col - 1, min + heat_loss, grid, score_grid);
    }

    if col < grid[0].len() - 1 && score.can_go(Direction::East) {
        let heat_loss = grid[row][col + 1];
        explore(row, col + 1, min + heat_loss, grid, score_grid);
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day17/input.txt").expect("Should have been able to read the file");

    let grid: Vec<Vec<u32>> = contents
        .lines()
        .map(|l| {
            l.chars()
                .map(|c| c.to_digit(10).expect("should be a number"))
                .collect()
        })
        .collect();

    let mut score_grid: Vec<Vec<BlockRecord>> =
        vec![vec![BlockRecord::new(u32::MAX); grid[0].len()]; grid.len()];

    explore(0, 0, 0, &grid, &mut score_grid);

    println!("{:?}", score_grid.last().unwrap().last().unwrap().value)
}
