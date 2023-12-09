use std::fs;

fn reduce_sequence(seq: Vec<i32>) -> Vec<i32> {
    let mut differences: Vec<i32> = Vec::new();
    for index in 0..seq.len() - 1 {
        differences.push(seq[index + 1] - seq[index]);
    }
    return differences;
}

fn next_in_sequence(seq: Vec<i32>) -> i32 {
    // zero the sequence
    let mut sequences = Vec::from([seq.clone()]);
    let mut current_sequence = seq;

    loop {
        let redeuced_sequence = reduce_sequence(current_sequence);

        if redeuced_sequence.iter().all(|x| x == &0) {
            // reached the base
            break;
        }
        sequences.push(redeuced_sequence.clone());
        current_sequence = redeuced_sequence;
    }

    // build up the next in the sequence
    let mut next: i32 = 0;

    // part 1
    // for _seq in sequences.into_iter().rev() {
    //     println!("{:?}", _seq);
    //     next = next + _seq.last().expect("_seq should have a last element");
    // }

    // part 2
    for _seq in sequences.into_iter().rev() {
        println!("{:?}", _seq);
        next = _seq.first().expect("_seq should have a first element") - next;
    }

    return next;
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
