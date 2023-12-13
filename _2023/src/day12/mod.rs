use std::{collections::HashMap, fs};

fn possible_ways(
    cache: &mut HashMap<(usize, usize, usize), usize>,
    s: &[char],
    within: Option<usize>,
    remaining: &[usize],
) -> usize {
    if s.is_empty() {
        return match (within, remaining.len()) {
            (None, 0) => 1, // we have no more damages to match and we have no extra #'s, this counts as valid
            (Some(x), 1) if x == remaining[0] => 1, // we can match the last remaining damage, this counts
            _ => 0,
        };
    }
    if within.is_some() && remaining.is_empty() {
        // we have #'s with no remaining damages to match, this isn't valid
        return 0;
    }

    let key = (s.len(), within.unwrap_or(0), remaining.len());
    if let Some(&x) = cache.get(&key) {
        // we already calculated this
        return x;
    }

    let ways = match (s[0], within) {
        ('.', Some(x)) if x != remaining[0] => 0,
        ('.', Some(_)) => possible_ways(cache, &s[1..], None, &remaining[1..]),
        ('.', None) => possible_ways(cache, &s[1..], None, remaining),
        ('#', Some(_)) => possible_ways(cache, &s[1..], within.map(|x| x + 1), remaining),
        ('#', None) => possible_ways(cache, &s[1..], Some(1), remaining),
        ('?', Some(x)) => {
            let mut ans = possible_ways(cache, &s[1..], within.map(|x| x + 1), remaining);
            if x == remaining[0] {
                ans += possible_ways(cache, &s[1..], None, &remaining[1..])
            }
            ans
        }
        ('?', None) => {
            possible_ways(cache, &s[1..], Some(1), remaining)
                + possible_ways(cache, &s[1..], None, remaining)
        }
        _ => unreachable!(),
    };
    cache.insert(key, ways);
    ways
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day12/input.txt").expect("Should have been able to read the file");
    let mut cache = HashMap::new();
    let springs: Vec<usize> = contents
        .lines()
        .map(|s| {
            let (row, damaged_str) = s.split_once(' ').expect("row and damaged");
            let damaged = damaged_str
                .split(',')
                .map(|x| x.parse::<usize>().expect("u32"))
                .collect::<Vec<_>>();
            cache.clear();
            let row2: String = (0..5).map(|_| row).collect::<Vec<_>>().join("?");
            let damaged2 = (0..5).flat_map(|_| damaged.clone()).collect::<Vec<usize>>();
            return possible_ways(
                &mut cache,
                row2.chars().collect::<Vec<_>>().as_slice(),
                None,
                &damaged2,
            );
        })
        .collect();

    println!("{:?}", springs.iter().sum::<usize>());
}
