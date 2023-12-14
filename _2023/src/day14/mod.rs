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

    fn tilt_south(&mut self) {
        // iter on the cols
        for x_index in 0..self.panels[0].len() {
            let mut spot_marker = self.panels.len() - 1;
            for y_index in (0..self.panels.len() - 1).rev() {
                if y_index >= spot_marker {
                    continue;
                }
                let spot_char = self.panels[spot_marker][x_index];
                if spot_char != '.' {
                    // not placeable, let's move forward.
                    spot_marker -= 1;
                    continue;
                }
                // we've got an open spot

                match self.panels[y_index][x_index] {
                    'O' => {
                        // swap
                        self.panels[spot_marker][x_index] = 'O';
                        self.panels[y_index][x_index] = '.';
                        spot_marker = spot_marker.saturating_sub(1)
                    }
                    '#' => {
                        // we need to move up the marker
                        spot_marker = y_index.saturating_sub(1)
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

    fn tilt_west(&mut self) {
        // iter on the cols
        for y_index in 0..self.panels.len() {
            let mut spot_marker = 0;
            for x_index in 1..self.panels[0].len() {
                if x_index <= spot_marker {
                    continue;
                }
                let spot_char = self.panels[y_index][spot_marker];
                if spot_char != '.' {
                    // not placeable, let's move forward.
                    spot_marker += 1;
                    continue;
                }
                // we've got an open spot

                match self.panels[y_index][x_index] {
                    'O' => {
                        // swap
                        self.panels[y_index][spot_marker] = 'O';
                        self.panels[y_index][x_index] = '.';
                        spot_marker = spot_marker.saturating_add(1)
                    }
                    '#' => {
                        // we need to move up the marker
                        spot_marker = x_index.saturating_add(1)
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

    fn tilt_east(&mut self) {
        // iter on the cols
        for y_index in 0..self.panels.len() {
            let mut spot_marker = self.panels[0].len() - 1;
            for x_index in (0..self.panels[0].len() - 1).rev() {
                if x_index >= spot_marker {
                    continue;
                }
                let spot_char = self.panels[y_index][spot_marker];
                if spot_char != '.' {
                    // not placeable, let's move forward.
                    spot_marker -= 1;
                    continue;
                }
                // we've got an open spot

                match self.panels[y_index][x_index] {
                    'O' => {
                        // swap
                        self.panels[y_index][spot_marker] = 'O';
                        self.panels[y_index][x_index] = '.';
                        spot_marker = spot_marker.saturating_sub(1)
                    }
                    '#' => {
                        // we need to move up the marker
                        spot_marker = x_index.saturating_sub(1)
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

    fn tilt_cycle(&mut self) {
        self.tilt_north();
        self.tilt_west();
        self.tilt_south();
        self.tilt_east();
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

fn is_cycle_cycle(cycle: &Vec<usize>, end_index: usize, total_loads: &Vec<usize>) -> bool {
    if cycle.is_empty() {
        return false;
    }
    // need 5 cycles to be considered a cycle
    // what should the bounds of this be?
    for offset in 0..2 {
        for i in 0..cycle.len() {
            let cycle_load = cycle[i];
            let total_load = total_loads[end_index
                .saturating_sub(cycle.len() * offset)
                .saturating_sub(i)];
            if cycle_load != total_load {
                return false;
            }
        }
    }
    return true;
}

fn extract_cycle_cycle(total_loads: Vec<usize>) -> Vec<usize> {
    let mut cycle: Vec<usize> = Vec::new();
    for (index, load) in total_loads.iter().enumerate().rev() {
        if is_cycle_cycle(&cycle, index, &total_loads) {
            // flip the order since we were doing this backwards
            cycle.reverse();
            return cycle;
        }

        cycle.push(*load);
    }
    unreachable!("there's always a cycle");
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day14/input.txt").expect("Should have been able to read the file");

    let mut dish = Dish {
        panels: contents.lines().map(|l| l.chars().collect()).collect(),
    };

    // println!("{:?}", dish.total_load());

    let mut cycle_total_loads = Vec::new();
    let cycles_we_calculate: u32 = 10000;
    let num_of_cycles: u32 = 1000000000;
    for _ in 0..cycles_we_calculate {
        dish.tilt_cycle();
        cycle_total_loads.push(dish.total_load());
    }

    let cycle = extract_cycle_cycle(cycle_total_loads);
    let offset = (num_of_cycles - cycles_we_calculate) as usize % cycle.len();
    println!("{:?}", cycle[offset - 1]) // 102943
}
