use std::{fmt, fs};

struct Dish {
    panels: Vec<Vec<char>>,
}

impl fmt::Debug for Dish {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for row in self.panels.iter().map(|l| l.iter().collect::<String>()) {
            let r = writeln!(f, "{}", row);
            if r.is_err() {
                return r;
            }
        }
        Ok(())
    }
}

impl Dish {
    fn tilt_north(&mut self) {
        // iter on the cols
        for x_index in 0..self.panels[0].len() {
            let mut spot_marker = 0;
            for y_index in 1..self.panels.len() {
                if y_index <= spot_marker {
                    continue;
                }
                let spot_char = self.panels[spot_marker][x_index];
                if spot_char != '.' {
                    // not placeable, let's move forward.
                    spot_marker += 1;
                    continue;
                }
                // we've got an open spot

                match self.panels[y_index][x_index] {
                    'O' => {
                        // swap
                        self.panels[spot_marker][x_index] = 'O';
                        self.panels[y_index][x_index] = '.';
                        spot_marker = spot_marker.saturating_add(1)
                    }
                    '#' => {
                        // we need to move up the marker
                        spot_marker = y_index.saturating_add(1)
                    }
                    '.' => {
                        // continue looking
                        continue;
                    }
                    _ => unreachable!(),
                }
            }
        }
    }

    fn total_load(&self) -> usize {
        let mut load = 0;

        for (y_index, row) in self.panels.iter().enumerate() {
            for (_, char) in row.iter().enumerate() {
                if char == &'O' {
                    load += self.panels.len() - y_index
                }
            }
        }
        return load;
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day14/input.txt").expect("Should have been able to read the file");

    let mut dish = Dish {
        panels: contents.lines().map(|l| l.chars().collect()).collect(),
    };
    dish.tilt_north();

    println!("{:?}", dish.total_load())
}
