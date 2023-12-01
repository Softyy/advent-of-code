mod day1;

use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.contains(&"day1".to_owned()) {
        day1::main()
    }
}
