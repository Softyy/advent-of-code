use std::{fs, ops::Not};

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day3/input.txt").expect("Should have been able to read the file");

    let grid: Vec<Vec<char>> = contents.lines().map(|x| x.chars().collect()).collect();

    fn is_part_number(digits: &Vec<(usize, usize)>, grid: &Vec<Vec<char>>) -> bool {
        // numbers are on a horizontal line
        let ignore_chars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
        let offsets = [
            (-1 as isize, -1 as isize),
            (-1, 0),
            (-1, 1),
            (0, -1),
            (0, 1),
            (1, -1),
            (1, 0),
            (1, 1),
        ];
        for digit in digits {
            for offset in offsets {
                let y: isize = (digit.1 as isize) + offset.1;
                if let Some(row) = grid.get(y as usize) {
                    let x: isize = (digit.0 as isize) + offset.0;
                    if let Some(char) = row.get(x as usize) {
                        if !ignore_chars.contains(char) {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    fn digits_to_i32(digits: &Vec<(usize, usize)>, grid: &Vec<Vec<char>>) -> i32 {
        let mut digit_chars: Vec<char> = Vec::new();
        for digit in digits {
            digit_chars.push(grid[digit.1][digit.0])
        }
        let digit_string: String = digit_chars.iter().collect();
        digit_string.parse::<i32>().expect("Should be an i32")
    }

    fn get_part_numbers(grid: &Vec<Vec<char>>) -> Vec<Vec<(usize, usize)>> {
        let width = grid.len();
        let height = grid[0].len();
        let mut part_nums: Vec<Vec<(usize, usize)>> = Vec::new();
        let mut possible_part_nums: Vec<Vec<(usize, usize)>> = Vec::new();
        let mut possible_part_num: Vec<(usize, usize)> = Vec::new();
        for y in 0..height {
            for x in 0..width {
                let digit = grid[y][x];
                if digit.is_digit(10) {
                    possible_part_num.push((x, y))
                } else {
                    if possible_part_num.is_empty().not() {
                        possible_part_nums.push(possible_part_num.clone());
                        possible_part_num.clear()
                    }
                }
            }
            // hack, just duplicate for now, handles nums at the edge
            if possible_part_num.is_empty().not() {
                possible_part_nums.push(possible_part_num.clone());
                possible_part_num.clear()
            }

            for possible_part_num in &possible_part_nums {
                if is_part_number(&possible_part_num, grid) {
                    part_nums.push(possible_part_num.to_vec())
                }
            }
            possible_part_nums.clear();
            possible_part_num.clear();
        }

        return part_nums;
    }

    fn extract_part_numbers_sum(grid: &Vec<Vec<char>>) -> i32 {
        let part_nums = get_part_numbers(grid);
        return part_nums
            .into_iter()
            .map(|x| digits_to_i32(&x, grid))
            .into_iter()
            .sum();
    }

    println!("{}", extract_part_numbers_sum(&grid)); // 527369

    // part 2

    fn calc_gear_ratio(
        maybe_gear: &(usize, usize),
        part_nums: &Vec<Vec<(usize, usize)>>,
        grid: &Vec<Vec<char>>,
    ) -> i32 {
        let offsets = [
            (-1 as isize, -1 as isize),
            (-1, 0),
            (-1, 1),
            (0, -1),
            (0, 1),
            (1, -1),
            (1, 0),
            (1, 1),
        ];

        let mut gear_nums: Vec<Vec<(usize, usize)>> = Vec::new();
        // try and find exactly 2 numbers, if so, it's a gear
        // this is bad, but I'm done with this day lol
        for part_num in part_nums {
            'outer: for offset in offsets {
                let x: isize = (maybe_gear.0 as isize) + offset.0;
                let y: isize = (maybe_gear.1 as isize) + offset.1;
                for part_num_digit in part_num {
                    if part_num_digit == &(x as usize, y as usize) {
                        gear_nums.push(part_num.clone());
                        break 'outer;
                    }
                }
            }
        }
        if gear_nums.len() == 2 {
            digits_to_i32(&gear_nums[0], grid) * digits_to_i32(&gear_nums[1], grid)
        } else {
            0
        }
    }

    fn extract_gear_ratios(grid: &Vec<Vec<char>>) -> i32 {
        let width = grid.len();
        let height = grid[0].len();
        let part_nums = get_part_numbers(grid);
        let mut gear_ratios: Vec<i32> = Vec::new();
        let mut possible_gears: Vec<(usize, usize)> = Vec::new();
        for y in 0..height {
            for x in 0..width {
                let digit = grid[y][x];
                if digit == '*' {
                    possible_gears.push((x, y))
                }
            }
        }

        for possible_gear in &possible_gears {
            gear_ratios.push(calc_gear_ratio(&possible_gear, &part_nums, &grid))
        }
        return gear_ratios.into_iter().sum();
    }

    println!("{}", extract_gear_ratios(&grid)); // 73074886
}
