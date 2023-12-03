use regex::{Captures, Regex};
use std::{collections::HashMap, fs};

struct Grab {
    red: i32,
    blue: i32,
    green: i32,
}

impl Grab {
    fn get(&self, field_string: &str) -> Result<i32, String> {
        match field_string {
            "red" => Ok(self.red),
            "blue" => Ok(self.blue),
            "green" => Ok(self.green),
            _ => Err(format!("invalid field name to get '{}'", field_string)),
        }
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day2/input.txt").expect("Should have been able to read the file");

    fn possible_set(grab: Grab) -> bool {
        let limits = Grab {
            red: 12,
            green: 13,
            blue: 14,
        };
        grab.blue <= limits.blue && grab.green <= limits.green && grab.red <= limits.red
    }

    fn unwrap_cap(cap: Option<Captures<'_>>) -> i32 {
        if cap.is_none() {
            return 0;
        }
        cap.unwrap()["count"].parse::<i32>().unwrap()
    }

    fn parse_set(set_string: &str) -> Grab {
        let red_match = Regex::new("(?<count>[0-9]+) red").unwrap();
        let blue_match = Regex::new("(?<count>[0-9]+) blue").unwrap();
        let green_match = Regex::new("(?<count>[0-9]+) green").unwrap();

        Grab {
            red: unwrap_cap(red_match.captures(set_string)),
            green: unwrap_cap(green_match.captures(set_string)),
            blue: unwrap_cap(blue_match.captures(set_string)),
        }
    }

    fn parse_game_line(game_string: &str) -> i32 {
        let (first, last) = game_string.split_once(":").unwrap();
        let possible_game = last.split(";").map(parse_set).all(possible_set);
        return if possible_game {
            first[5..].parse::<i32>().unwrap()
        } else {
            0
        };
    }

    // part 1
    let value: i32 = contents.lines().map(parse_game_line).sum();
    println!("{}", value); // 2476

    // part 2
    fn calculate_power_set(sets: Vec<Grab>) -> i32 {
        let keys = ["red", "green", "blue"];
        let mut mins: HashMap<&str, i32> = HashMap::new();
        for set in sets {
            for block in keys {
                let set_block = set.get(block).unwrap();
                if set_block > *mins.get(block).unwrap_or(&0) {
                    mins.insert(block, set_block);
                }
            }
        }
        return mins.values().copied().reduce(|a, b| a * b).unwrap();
    }

    fn parse_game_line_2(game_string: &str) -> i32 {
        let sets: Vec<Grab> = game_string
            .split(":")
            .last()
            .unwrap()
            .split(";")
            .map(parse_set)
            .collect();

        return calculate_power_set(sets);
    }

    let value: i32 = contents.lines().map(parse_game_line_2).sum();
    println!("{}", value); // 54911
}
