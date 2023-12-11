#![feature(iter_array_chunks)]

mod day1;
mod day10;
mod day11;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;
mod day7;
mod day8;
mod day9;

use std::env;

use regex::Regex;

fn main() {
    let args: Vec<String> = env::args().collect();

    let days = [
        day1::main,
        day2::main,
        day3::main,
        day4::main,
        day5::main,
        day6::main,
        day7::main,
        day8::main,
        day9::main,
        day10::main,
        day11::main,
    ];

    let day_match = Regex::new("day(?<day_number>[0-9]+)").unwrap();

    for arg in args {
        match day_match.captures(&arg) {
            Some(capture) => {
                let day_number: usize = capture["day_number"]
                    .parse::<usize>()
                    .expect("should be a day number");
                match days.get(day_number - 1) {
                    Some(func) => func(),
                    _ => println!("No func for {}", arg),
                }
            }
            _ => {}
        }
    }
}
