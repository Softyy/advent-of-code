use std::fs;

use regex::Regex;

struct LineSegment {
    length: i64,
    dir: char,
}

impl LineSegment {
    fn delta(&self) -> (i64, i64) {
        match self.dir {
            'R' => (self.length, 0),
            'L' => (-1 * self.length, 0),
            'U' => (0, -1 * self.length),
            'D' => (0, self.length),
            _ => unreachable!(),
        }
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day18/input.txt").expect("Should have been able to read the file");

    let dig_reg =
        Regex::new(r"^(?<dir>[RLUD])\s(?<dist>\d+)\s\(\#(?<colour>[0-9a-fA-F]+)\)$").unwrap();

    let mut path1: Vec<LineSegment> = Vec::new();
    let mut path2: Vec<LineSegment> = Vec::new();

    let mut perimiter: i64 = 0;
    let mut area: i64 = 0;

    // https://en.wikipedia.org/wiki/Green%27s_theorem
    // i.e. Area =  Int_{path}  x * dy

    fn dir_digit_to_char(dir_digit: &str) -> char {
        let char = dir_digit.chars().next().expect("should be the dir digit");
        match char {
            '0' => 'R',
            '1' => 'D',
            '2' => 'L',
            '3' => 'U',
            _ => unreachable!(),
        }
    }

    for line in contents.lines() {
        let capture = dig_reg.captures(line).expect("Should match regex");

        let dir = capture["dir"].chars().next().expect("Should have a dir");
        let dist = capture["dist"].parse::<i64>().expect("Should have a dist");
        let (hex_str, dir_digit) = capture["colour"].split_at(5);

        path1.push(LineSegment { length: dist, dir });
        path2.push(LineSegment {
            length: i64::from_str_radix(hex_str, 16).expect("it's should be a hex"),
            dir: dir_digit_to_char(dir_digit),
        })
    }

    // do the line integral + pick's theorem
    let mut pos = (0, 0);
    for seg in path2 {
        let delta = seg.delta();
        perimiter += seg.length as i64;
        area += pos.0 * delta.1;
        pos = (pos.0 + delta.0, pos.1 + delta.1);
    }

    println!("{}", area + perimiter / 2 + 1); // 52055

    //part 2: 67622758357096
}
