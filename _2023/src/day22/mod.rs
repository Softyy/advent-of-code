use std::{
    collections::{HashMap, HashSet},
    fs,
};

#[derive(Debug, Clone)]
struct Point(usize, usize, usize);

#[derive(Debug, Clone)]
struct Block {
    p1: Point,
    p2: Point,
}

impl Block {
    fn from_coord_str(start_coords: &str, end_coords: &str) -> Self {
        let mut start = start_coords.split(",").map(|d| d.parse::<usize>().unwrap());
        let mut end = end_coords.split(",").map(|d| d.parse::<usize>().unwrap());
        return Self {
            p1: Point(
                start.next().unwrap(),
                start.next().unwrap(),
                start.next().unwrap(),
            ),
            p2: Point(
                end.next().unwrap(),
                end.next().unwrap(),
                end.next().unwrap(),
            ),
        };
    }

    fn points(&self) -> Vec<Point> {
        let mut points: Vec<Point> = Vec::new();

        match (
            self.p1.0 != self.p2.0,
            self.p1.1 != self.p2.1,
            self.p1.2 != self.p2.2,
        ) {
            (true, false, false) => {
                for x in self.p1.0..self.p2.0 + 1 {
                    points.push(Point(x, self.p1.1, self.p1.2));
                }
            }
            (false, true, false) => {
                for y in self.p1.1..self.p2.1 + 1 {
                    points.push(Point(self.p1.0, y, self.p1.2));
                }
            }
            (false, false, true) => {
                for z in self.p1.2..self.p2.2 + 1 {
                    points.push(Point(self.p1.0, self.p1.1, z));
                }
            }
            (false, false, false) => {
                // block of 1
                points.push(Point(self.p1.0, self.p1.1, self.p1.2));
            }
            _ => unreachable!(),
        }
        return points;
    }
}

#[derive(Debug)]
struct Stack {
    pos: Vec<Vec<Vec<usize>>>,
    num_blocks: usize,
    block_map: HashMap<usize, Block>,
}

impl Stack {
    fn new(blocks: Vec<Block>) -> Self {
        let max_x: usize = blocks.iter().map(|b| b.p2.0 + 1 as usize).max().unwrap();
        let max_y: usize = blocks.iter().map(|b| b.p2.1 + 1 as usize).max().unwrap();
        let max_z: usize = blocks.iter().map(|b| b.p2.2 + 1 as usize).max().unwrap();

        let mut pos: Vec<Vec<Vec<usize>>> = vec![vec![vec![0; max_x]; max_y]; max_z];
        let mut map: HashMap<usize, Block> = HashMap::new();
        for (index, block) in blocks.iter().enumerate() {
            map.insert(index + 1, block.clone());
            for p in block.points() {
                pos[p.2][p.1][p.0] = index + 1;
            }
        }
        return Self {
            pos,
            num_blocks: blocks.len(),
            block_map: map,
        };
    }

    fn apply_gravity(&mut self) {
        // start from the ground, and see if blocks can fall

        let settled_blocks: HashSet<usize> = HashSet::new();

        for z in 1..self.pos.len() {
            let mut blocks_on_z: HashSet<usize> = HashSet::new();

            for y in 0..self.pos[z].len() {
                for x in 0..self.pos[z][y].len() {
                    let cell = self.pos[z][y][x];
                    if cell != 0 {
                        blocks_on_z.insert(cell);
                    }
                }
            }

            // check if blocks on the level can fall

            for block_label in blocks_on_z {
                if settled_blocks.contains(&block_label) {
                    // this block has already settled, no need to check
                    continue;
                }
                let mut _z = z;
                self.block_map.entry(block_label).and_modify(|block| {
                    while _z > 1 {
                        let mut points_on_z = block.points().into_iter().filter(|p| p.2 == _z);
                        if !points_on_z.all(|p| self.pos[p.2 - 1][p.1][p.0] == 0) {
                            // the block can't fall any more
                            break;
                        }
                        // move the block down 1 and update the pos of the stack
                        for p in block.points() {
                            self.pos[p.2][p.1][p.0] = 0;
                        }
                        *block = Block {
                            p1: Point(block.p1.0, block.p1.1, block.p1.2 - 1),
                            p2: Point(block.p2.0, block.p2.1, block.p2.2 - 1),
                        };
                        for p in block.points() {
                            self.pos[p.2][p.1][p.0] = block_label;
                        }
                        _z -= 1;
                    }
                });
            }
        }
    }

    fn can_remove_block(&self, block_label: usize) -> bool {
        // only have to check if the top layer is supporting a block,
        // and if there's another support on that block.
        let block = self.block_map.get(&block_label).unwrap();

        // does this block support a block?
        let mut supporting_blocks: HashSet<usize> = HashSet::new();
        for p in block.points() {
            let above = Point(p.0, p.1, p.2 + 1);

            if above.2 >= self.pos.len() {
                continue;
            }
            let above_block = self.pos[above.2][above.1][above.0];
            if above_block != 0 && above_block != block_label {
                supporting_blocks.insert(above_block);
            }
        }

        if supporting_blocks.is_empty() {
            return true;
        }

        // is block supported by at least 2 blocks
        for supporting_block in supporting_blocks {
            let s_block = self.block_map.get(&supporting_block).unwrap();
            let mut supported_by_blocks: HashSet<usize> = HashSet::new();
            for p in s_block.points() {
                let below = Point(p.0, p.1, p.2 - 1);
                if below.2 < 1 {
                    continue;
                }
                let below_block = self.pos[below.2][below.1][below.0];
                if below_block != 0 && below_block != supporting_block {
                    supported_by_blocks.insert(below_block);
                }
            }

            if supported_by_blocks.len() > 1 {
                return true;
            }
        }

        false
    }

    fn disintegrate(&self) -> u32 {
        let mut count = 0;
        for block_label in 1..self.num_blocks + 1 {
            if self.can_remove_block(block_label) {
                count += 1;
            }
        }
        return count;
    }

    fn display(&self, front: bool) {
        for z in (0..self.pos.len()).rev() {
            if front {
                for y in 0..self.pos[z].len() {
                    let row = &self.pos[z][y];
                    let mut s = String::new();
                    for cell in row {
                        s.push_str(&cell.to_string())
                    }
                    println!("{}", s)
                }
                let mut s = String::new();
            }
        }
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day22/test.txt").expect("Should have been able to read the file");

    let blocks: Vec<Block> = contents
        .lines()
        .map(|l| {
            let (start, end) = l.split_once("~").unwrap();
            return Block::from_coord_str(start, end);
        })
        .collect();

    let mut stack = Stack::new(blocks);
    stack.display(true);
    stack.apply_gravity();
    stack.display(true);

    let blocks_that_can_be_removed = stack.disintegrate();

    println!("{}", blocks_that_can_be_removed); // 576 (too high)
}
