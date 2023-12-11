use std::fs;

#[derive(Debug)]
struct Point {
    x: usize,
    y: usize,
}

fn abs_difference(x1: usize, x2: usize) -> usize {
    if x1 < x2 {
        x2 - x1
    } else {
        x1 - x2
    }
}

fn contains(v: &usize, x1: &usize, x2: &usize) -> bool {
    if x1 < x2 {
        x1 < v && v < x2
    } else {
        x2 < v && v < x1
    }
}

fn manhattan(p1: &Point, p2: &Point) -> usize {
    abs_difference(p1.x, p2.x) + abs_difference(p1.y, p2.y)
}

#[derive(Debug)]
struct Universe {
    image: Vec<Vec<char>>,
}

impl Universe {
    fn empty_horizontal_lines(&self) -> Vec<usize> {
        let mut indicies: Vec<usize> = Vec::new();
        for (index, row) in self.image.iter().enumerate() {
            if row.iter().all(|g| g == &'.') {
                indicies.push(index);
            }
        }
        return indicies;
    }

    fn empty_vertical_lines(&self) -> Vec<usize> {
        let mut indicies: Vec<usize> = Vec::new();
        'outer: for index in 0..self.image[0].len() {
            for r_index in 0..self.image.len() {
                let g = self.image[r_index][index];
                if g != '.' {
                    continue 'outer;
                }
            }
            indicies.push(index);
        }
        return indicies;
    }

    fn grow(&mut self) {
        let verticals_to_grow = self.empty_vertical_lines();
        for row in self.image.iter_mut() {
            let mut offset: usize = 0;
            for new_index in verticals_to_grow.iter() {
                // double it
                row.insert(new_index + offset, '.');
                offset += 1;
            }
        }

        let horizontals_to_grow = self.empty_horizontal_lines();
        let length = self.image[0].len();

        let mut offset: usize = 0;
        for new_index in horizontals_to_grow.iter() {
            // double it
            self.image.insert(new_index + offset, vec!['.'; length]);
            offset += 1;
        }
    }

    fn galaxies(&self) -> Vec<Point> {
        let mut spaces: Vec<Point> = Vec::new();
        for (y, row) in self.image.iter().enumerate() {
            for (x, space) in row.into_iter().enumerate() {
                if space == &'#' {
                    spaces.push(Point { x, y });
                }
            }
        }
        return spaces;
    }

    fn shortest_path_between_galaxies(&self) -> Vec<usize> {
        let galaxies = self.galaxies();
        let mut shortest_paths: Vec<usize> = Vec::new();

        for i in 0..(galaxies.len() - 1) {
            for j in i + 1..galaxies.len() {
                let dist = manhattan(&galaxies[i], &galaxies[j]);
                shortest_paths.push(dist)
            }
        }
        return shortest_paths;
    }

    fn shortest_path_between_galaxies_smart(&self) -> Vec<usize> {
        let galaxies = self.galaxies();
        let mut shortest_paths: Vec<usize> = Vec::new();

        let verticals_to_grow = self.empty_vertical_lines();
        let horizontals_to_grow = self.empty_horizontal_lines();

        for i in 0..(galaxies.len() - 1) {
            for j in i + 1..galaxies.len() {
                let pi = &galaxies[i];
                let pj = &galaxies[j];
                let mut x_offset: usize = 0;
                let mut y_offset: usize = 0;
                for vertical in verticals_to_grow.iter() {
                    if contains(vertical, &pi.x, &pj.x) {
                        y_offset += 999999;
                    }
                }
                for horizontal in horizontals_to_grow.iter() {
                    if contains(horizontal, &pi.y, &pj.y) {
                        x_offset += 999999;
                    }
                }
                let dist = manhattan(&galaxies[i], &galaxies[j]) + y_offset + x_offset;
                shortest_paths.push(dist)
            }
        }
        return shortest_paths;
    }

    fn display(&self) {
        for row in self.image.iter() {
            println!("{}", row.iter().collect::<String>());
        }
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day11/input.txt").expect("Should have been able to read the file");

    let mut universe = Universe {
        image: contents
            .lines()
            .map(|l| l.chars().collect::<Vec<char>>())
            .collect(),
    };

    // universe.grow();
    let dists: Vec<usize> = universe.shortest_path_between_galaxies_smart();
    universe.display();
    println!("{}", dists.iter().sum::<usize>()); // part 1: 9742154, part 2: 411142919886
}
