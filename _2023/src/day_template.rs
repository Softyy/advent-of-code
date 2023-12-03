use std::fs;

pub fn main() {
    let contents: String =
        fs::read_to_string("src/dayN/input.txt").expect("Should have been able to read the file");
    panic!("Implement me")
}
