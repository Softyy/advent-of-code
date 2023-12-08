#![feature(iter_array_chunks)]

mod day1;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;
mod day7;
mod day8;

use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.contains(&"day1".to_owned()) {
        day1::main()
    }

    if args.contains(&"day2".to_owned()) {
        day2::main()
    }

    if args.contains(&"day3".to_owned()) {
        day3::main();
    }

    if args.contains(&"day4".to_owned()) {
        day4::main();
    }

    if args.contains(&"day5".to_owned()) {
        day5::main();
    }

    if args.contains(&"day6".to_owned()) {
        day6::main();
    }

    if args.contains(&"day7".to_owned()) {
        day7::main();
    }

    if args.contains(&"day8".to_owned()) {
        day8::main();
    }
}
