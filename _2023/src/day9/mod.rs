use std::fs;

fn reduce_sequence(seq: Vec<i32>) -> Vec<i32> {
    let mut differences: Vec<i32> = Vec::new();
    for index in 0..seq.len() - 1 {
        differences.push(seq[index + 1] - seq[index]);
    }
    return differences;
}

fn next_in_sequence(seq: Vec<i32>) -> i32 {
    if seq.iter().all(|x| x == &0) {
        // reached the base
        return 0;
    } else {
        // part 1
        // let end_of_seq = *seq.last().expect("Should have a last element");
        // return end_of_seq + next_in_sequence(reduce_sequence(seq));

        // part 2
        let first_of_seq = *seq.first().expect("Should have a first element");
        return first_of_seq - next_in_sequence(reduce_sequence(seq));
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day9/input.txt").expect("Should have been able to read the file");

    let total: i32 = contents
        .lines()
        .map(|x| {
            x.split_whitespace()
                .map(|x| x.parse::<i32>().expect("i32"))
                .collect::<Vec<i32>>()
        })
        .map(next_in_sequence)
        .sum();
    println!("{}", total) // part 1: 1901217887, part 2: 905
}
