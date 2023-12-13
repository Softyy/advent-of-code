use std::{collections::HashMap, fs};

fn transpose<T>(v: Vec<Vec<T>>) -> Vec<Vec<T>> {
    assert!(!v.is_empty());
    let len = v[0].len();
    let mut iters: Vec<_> = v.into_iter().map(|n| n.into_iter()).collect();
    (0..len)
        .map(|_| {
            iters
                .iter_mut()
                .map(|n| n.next().unwrap())
                .collect::<Vec<T>>()
        })
        .collect()
}

fn count_differences(v1: &Vec<char>, v2: &Vec<char>) -> u64 {
    let mut mismatch_count = 0;
    for (a, b) in v1.iter().zip(v2) {
        if a != b {
            mismatch_count += 1;
        }
    }

    return mismatch_count;
}

fn calc_vertical_reflection(pattern: &Vec<Vec<char>>) -> i64 {
    let pattern_t = transpose(pattern.clone());
    return calc_horiztonal_reflection(&pattern_t);
}

fn calc_horiztonal_reflection(pattern: &Vec<Vec<char>>) -> i64 {
    let mut full_reflection = false;
    let mut matches = 0;
    let mut matches_per_line: HashMap<usize, i64> = HashMap::new();
    'outer: for i in 0..pattern.len() - 1 {
        let mut top_index = i;
        let mut bottom_index = i + 1;
        let mut freebie_mismatch: bool = true;

        loop {
            let r1 = &pattern[top_index];
            let r2 = &pattern[bottom_index];

            if !r1.iter().zip(r2).all(|(a, b)| a == b) {
                break;
            }
            // the row is equal

            matches += 1;
            if top_index == 0 || bottom_index == pattern.len() - 1 {
                // out of bounds checks
                full_reflection = true;
                matches_per_line.entry(i).or_insert(matches);
                break 'outer;
            }
            top_index -= 1;
            bottom_index += 1;
        }
        matches = 0;
    }

    if !full_reflection {
        return 0;
    }

    return matches_per_line
        .into_iter()
        .max_by(|a, b| a.1.cmp(&b.1))
        .map(|(k, _v)| k as i64)
        .unwrap()
        + 1; // indicies are 0 indexed, add 1 to get the count
}

fn calc_vertical_reflection_2(pattern: &Vec<Vec<char>>, avoid_index: usize) -> i64 {
    println!("vert");
    let pattern_t = transpose(pattern.clone());
    return calc_horiztonal_reflection_2(&pattern_t, avoid_index);
}

fn calc_horiztonal_reflection_2(pattern: &Vec<Vec<char>>, avoid_index: usize) -> i64 {
    let mut full_reflection = false;
    let mut matches = 0;
    let mut matches_per_line: HashMap<usize, u64> = HashMap::new();
    'outer: for i in 0..pattern.len() - 1 {
        if i == avoid_index {
            continue;
        }
        let mut top_index = i;
        let mut bottom_index = i + 1;
        let mut freebie_mismatch: bool = true;

        loop {
            let r1 = &pattern[top_index];
            let r2 = &pattern[bottom_index];

            println!();
            println!("{:?},{}", r1, top_index);
            println!("{:?},{}", r2, bottom_index);

            match count_differences(&r1, &r2) {
                0 => {} // all match
                1 => {
                    if !freebie_mismatch {
                        break;
                    } else {
                        freebie_mismatch = false
                    }
                }
                _ => break,
            }

            println!("match");

            // the row is equal

            matches += 1;

            if top_index == 0 || bottom_index == pattern.len() - 1 {
                // out of bounds checks
                full_reflection = true;
                matches_per_line.entry(i).or_insert(matches);
                break 'outer;
            }
            top_index -= 1;
            bottom_index += 1;
        }
        matches = 0;
    }

    if !full_reflection {
        return 0;
    }

    return matches_per_line
        .into_iter()
        .max_by(|a, b| a.1.cmp(&b.1))
        .map(|(k, _v)| k as i64)
        .unwrap()
        + 1; // indicies are 0 indexed, add 1 to get the count
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day13/input.txt").expect("Should have been able to read the file");

    let mut current_pattern: Vec<Vec<char>> = Vec::new();

    let mut p1_ans: i64 = 0;
    let mut p2_ans: i64 = 0;

    for line in contents.lines() {
        if line.is_empty() {
            // new mirror
            let v_ans = calc_vertical_reflection(&current_pattern);
            let h_ans = calc_horiztonal_reflection(&current_pattern);

            p1_ans += v_ans;
            p2_ans += calc_vertical_reflection_2(
                &current_pattern,
                if v_ans > 0 {
                    v_ans as usize - 1
                } else {
                    usize::MAX
                },
            );

            p1_ans += h_ans * 100;
            p2_ans += calc_horiztonal_reflection_2(
                &current_pattern,
                if h_ans > 0 {
                    h_ans as usize - 1
                } else {
                    usize::MAX
                },
            ) * 100;

            current_pattern.clear();
            continue;
        }
        current_pattern.push(line.chars().collect());
    }

    if !current_pattern.is_empty() {
        // new mirror
        let v_ans = calc_vertical_reflection(&current_pattern);
        let h_ans = calc_horiztonal_reflection(&current_pattern);

        p1_ans += v_ans;
        p2_ans += calc_vertical_reflection_2(
            &current_pattern,
            if v_ans > 0 {
                v_ans as usize - 1
            } else {
                usize::MAX
            },
        );

        p1_ans += h_ans * 100;
        p2_ans += calc_horiztonal_reflection_2(
            &current_pattern,
            if h_ans > 0 {
                h_ans as usize - 1
            } else {
                usize::MAX
            },
        ) * 100;
    }
    println!("{}", p1_ans);
    println!("{}", p2_ans);
}
