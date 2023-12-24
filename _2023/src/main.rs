#![feature(iter_array_chunks)]

mod day1;
mod day10;
mod day11;
mod day12;
mod day13;
mod day14;
mod day15;
mod day16;
mod day18;
mod day19;
mod day2;
mod day20;
mod day21;
mod day22;
mod day3;
mod day4;
mod day5;
mod day6;
mod day7;
mod day8;
mod day9;
mod utils;

use regex::Regex;
use std::env;

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
        day12::main,
        day13::main,
        day14::main,
        day15::main,
        day16::main,
        day18::main,
        day19::main,
        day20::main,
        day21::main,
        day22::main,
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
