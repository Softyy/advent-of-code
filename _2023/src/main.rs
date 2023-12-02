mod day1;
mod day2;

use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.contains(&"day1".to_owned()) {
        day1::main()
    }

    if args.contains(&"day2".to_owned()) {
        day2::main()
    }
}
