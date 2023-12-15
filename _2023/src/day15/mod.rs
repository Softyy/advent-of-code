use std::{collections::HashMap, fs, mem::replace};

#[derive(Debug, Clone)]
struct Lens {
    label: String,
    focal: u32,
}

fn hash(s: &str) -> u32 {
    _hash(s, 0)
}

fn _hash(s: &str, mut value: u32) -> u32 {
    if s.len() == 0 {
        return value;
    }

    let char = s.chars().next().unwrap();

    value += char as u32;
    value *= 17;
    value %= 256;

    return _hash(&s[1..], value);
}

fn total_focus_power(boxes: HashMap<u32, Vec<Lens>>) -> u32 {
    let mut value = 0;
    for (_box, lenses) in boxes {
        for (index, lens) in lenses.iter().enumerate() {
            value += (_box + 1) * (index as u32 + 1) * lens.focal
        }
    }
    return value;
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day15/input.txt").expect("Should have been able to read the file");
    let total: u32 = contents.split(',').map(hash).sum();

    println!("{}", total);

    // part 2

    let mut boxes: HashMap<u32, Vec<Lens>> = HashMap::new();

    for entry in contents.split(',') {
        if entry.contains('=') {
            let (label, focal) = entry.split_once('=').unwrap();
            let _box = hash(label);
            let lens = Lens {
                label: label.to_string(),
                focal: focal.parse::<u32>().unwrap(),
            };
            boxes
                .entry(_box)
                .and_modify(|v| {
                    let maybe_index = v.iter().position(|lens| lens.label == label);
                    match maybe_index {
                        Some(index) => {
                            let _ = replace(&mut v[index], lens);
                        }
                        _ => v.push(lens),
                    };
                })
                .or_insert(Vec::from([Lens {
                    label: label.to_string(),
                    focal: focal.parse::<u32>().unwrap(),
                }]));
        } else {
            // contains -
            let label = &entry[0..entry.len() - 1];
            let _box = hash(label);
            boxes.entry(_box).and_modify(|v| {
                let maybe_index = v.iter().position(|lens| lens.label == label);
                match maybe_index {
                    Some(index) => {
                        v.remove(index);
                    }
                    _ => {}
                };
            });
        }
    }

    let ans = total_focus_power(boxes);

    println!("{}", ans);
}
