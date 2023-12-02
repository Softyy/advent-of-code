use regex::{Captures, Regex};
use relative_path::RelativePath;
use std::{collections::HashMap, env::current_dir, fs};

struct Grab {
    red: i32,
    blue: i32,
    green: i32,
}

pub fn main() {
    // TODO: move to util
    let current_dir = current_dir();
    // TODO: why wasn't relative path working?
    let relative_path = RelativePath::new("src/day2/input.txt");
    let file_path = relative_path.to_path(current_dir.unwrap());
    let contents: String =
        fs::read_to_string(file_path).expect("Should have been able to read the file");

    fn possible_set(grab: Grab) -> bool {
        let limits = Grab {
            red: 12,
            green: 13,
            blue: 14,
        };
        grab.blue <= limits.blue && grab.green <= limits.green && grab.red <= limits.red
    }

    fn possible_game(sets: Vec<Grab>) -> bool {
        sets.into_iter().all(possible_set)
    }

    fn unwrap_cap(cap: Option<Captures<'_>>) -> i32 {
        if cap.is_some() {
            cap.unwrap()["count"].parse::<i32>().unwrap()
        } else {
            0
        }
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
        let game_id = game_string.split(":").next().unwrap()[5..]
            .parse::<i32>()
            .unwrap();

        let sets: Vec<Grab> = game_string
            .split(":")
            .last()
            .unwrap()
            .split(";")
            .map(parse_set)
            .collect();

        return if possible_game(sets) { game_id } else { 0 };
    }

    // part 1
    let value: i32 = contents.lines().map(parse_game_line).sum();
    println!("{}", value); // 2476

    // part 2
    fn calculate_power_set(sets: Vec<Grab>) -> i32 {
        let mut mins = HashMap::from([("red", 0), ("green", 0), ("blue", 0)]);
        for set in sets {
            if set.blue > *mins.get("blue").unwrap() {
                mins.insert("blue", set.blue);
            }
            if set.green > *mins.get("green").unwrap() {
                mins.insert("green", set.green);
            }
            if set.red > *mins.get("red").unwrap() {
                mins.insert("red", set.red);
            }
        }

        return mins.get("red").unwrap() * mins.get("blue").unwrap() * mins.get("green").unwrap();
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
    println!("{}", value); // 2476
}
