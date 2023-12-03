use std::collections::HashMap;
use std::fs;

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day1/input.txt").expect("Should have been able to read the file");

    // Part 1
    fn find_digit_left_to_right(string: &str) -> char {
        let digits: [char; 10] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

        for character in string.chars() {
            if digits.contains(&character) {
                return character;
            }
        }
        panic!("Character was not present, problem with input")
    }

    fn find_digit_right_to_left(string: &str) -> char {
        let digits: [char; 10] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

        for character in string.chars().rev() {
            if digits.contains(&character) {
                return character;
            }
        }
        panic!("Character was not present, problem with input")
    }

    fn find_two_digit_int(string: &str) -> i32 {
        let digit = format!(
            "{}{}",
            find_digit_left_to_right(string),
            find_digit_right_to_left(string)
        );
        digit.parse::<i32>().unwrap()
    }

    let value: i32 = contents.lines().map(find_two_digit_int).sum();
    println!("{:?}", value); // 55386

    // Part 2

    fn str_num_caster(string: &str, left_to_right: bool) -> String {
        let left_key_map: HashMap<&str, &str> = HashMap::from([
            ("oneight", "1ight"),
            ("twone", "2ne"),
            ("threeight", "3ight"),
            ("fiveight", "5ight"),
            ("sevenine", "7ine"),
            ("eightwo", "8wo"),
            ("eighthree", "8hree"),
            ("nineight", "9ight"),
        ]);

        let right_key_map: HashMap<&str, &str> = HashMap::from([
            ("oneight", "on8"),
            ("twone", "tw1"),
            ("threeight", "thre8"),
            ("fiveight", "fiv8"),
            ("sevenine", "seve9"),
            ("eightwo", "eigh2"),
            ("eighthree", "eigh3"),
            ("nineight", "nin8"),
        ]);

        let key_map: HashMap<&str, &str> = HashMap::from([
            ("one", "1"),
            ("two", "2"),
            ("three", "3"),
            ("four", "4"),
            ("five", "5"),
            ("six", "6"),
            ("seven", "7"),
            ("eight", "8"),
            ("nine", "9"),
        ]);

        let mut new_string = string.to_string();
        let map = if left_to_right {
            left_key_map
        } else {
            right_key_map
        };
        for num in map.keys() {
            let digit = map.get(num).unwrap();
            new_string = new_string.replace(num, digit);
        }
        for num in key_map.keys() {
            let digit = key_map.get(num).unwrap();
            new_string = new_string.replace(num, digit);
        }
        return new_string;
    }

    fn find_two_digit_with_cast_int(string: &str) -> i32 {
        let left = find_digit_left_to_right(str_num_caster(string, true).as_str());
        let right = find_digit_right_to_left(str_num_caster(string, false).as_str());
        let digit = format!("{}{}", left, right);
        digit.parse::<i32>().unwrap()
    }

    let value: i32 = contents.lines().map(find_two_digit_with_cast_int).sum();

    println!("{:?}", value); // 54824
}
