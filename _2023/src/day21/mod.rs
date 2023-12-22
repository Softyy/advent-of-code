use std::{fmt, fs};

enum Tile {
    Rock,
    Plot(u32),
}

struct Point(usize, usize);

struct Grid {
    tiles: Vec<Vec<Tile>>,
    max: u32,
}

impl Grid {
    fn fill(&mut self, p: Point, dist: u32) {
        if p.1 >= self.tiles.len() || p.0 >= self.tiles[p.1].len() || dist > self.max {
            return;
        }
        match self.tiles[p.1][p.0] {
            Tile::Rock => {}
            Tile::Plot(current_best) => {
                if current_best > dist {
                    self.tiles[p.1][p.0] = Tile::Plot(dist);
                    self.fill(Point(p.0, p.1.saturating_add(1)), dist + 1);
                    self.fill(Point(p.0, p.1.saturating_sub(1)), dist + 1);
                    self.fill(Point(p.0.saturating_add(1), p.1), dist + 1);
                    self.fill(Point(p.0.saturating_sub(1), p.1), dist + 1);
                }
            }
        }
    }

    fn exact_steps(&self) -> u32 {
        let mut count: u32 = 0;
        for row in &self.tiles {
            for tile in row {
                match tile {
                    Tile::Rock => {}
                    Tile::Plot(u32::MAX) => {}
                    Tile::Plot(dist) => {
                        let is_even = self.max % 2 == 0;
                        if is_even && dist % 2 == 0 {
                            count += 1;
                        } else if !is_even && dist & 2 == 1 {
                            count += 1;
                        }
                    }
                }
            }
        }
        return count;
    }
}

impl fmt::Debug for Grid {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for row in self.tiles.iter().map(|l| {
            l.iter()
                .map(|t| match t {
                    Tile::Rock => '#',
                    Tile::Plot(dist) => {
                        if dist == &u32::MAX {
                            '.'
                        } else {
                            '0'
                        }
                    }
                })
                .collect::<String>()
        }) {
            let r = writeln!(f, "{}", row);
            if r.is_err() {
                return r;
            }
        }
        Ok(())
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day21/test.txt").expect("Should have been able to read the file");

    let mut grid = Grid {
        tiles: Vec::new(),
        //max: 6
        // max: 64, // part 1
        max: 50, // max: 26501365 // part 2
    };
    let mut start = Point(0, 0);

    for (row, line) in contents.lines().enumerate() {
        let mut tile_row: Vec<Tile> = Vec::new();
        for (col, char) in line.chars().enumerate() {
            match char {
                '.' => tile_row.push(Tile::Plot(u32::MAX)),
                '#' => tile_row.push(Tile::Rock),
                'S' => {
                    tile_row.push(Tile::Plot(u32::MAX));
                    start = Point(col, row);
                }
                _ => unreachable!(),
            }
        }
        grid.tiles.push(tile_row);
    }
    grid.fill(start, 0);
    println!("{:?}", grid);

    println!("{}", grid.exact_steps())
}
