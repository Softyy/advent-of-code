use std::{collections::HashMap, fs, str::Chars};

use gcd::Gcd;

fn traverse_tree(
    mut steps_count: u64,
    starting_node: &str,
    directions: &Chars<'_>,
    nodes: &HashMap<&str, (&str, &str)>,
    ends_with: &str,
) -> u64 {
    let mut current_node = starting_node;

    for direction in directions.clone() {
        steps_count += 1;
        match direction {
            'L' => current_node = nodes.get(&current_node).expect("Node missing").0,
            'R' => current_node = nodes.get(&current_node).expect("Node missing").1,
            _ => panic!("Directions should be L or R"),
        }
        if current_node.ends_with(ends_with) {
            // we've found the end
            return steps_count;
        }
    }
    // we've gone through the directions once and haven't found the end, we need to go deeper
    return traverse_tree(steps_count, current_node, directions, nodes, ends_with);
}

fn calculate_cycle(
    starting_node: &str,
    directions: &Chars<'_>,
    nodes: &HashMap<&str, (&str, &str)>,
) -> u64 {
    let initial_count = traverse_tree(0, starting_node, directions, nodes, "Z");
    let cycle_count = traverse_tree(initial_count, starting_node, directions, nodes, "Z");
    return cycle_count - initial_count;
}

fn lcm(a: u64, b: u64) -> u64 {
    a * b / a.gcd(b)
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day8/input.txt").expect("Should have been able to read the file");
    let mut lines = contents.lines();
    let directions = lines.next().expect("Should have directions").chars();

    lines.next();

    // create map to build tree
    let mut nodes: HashMap<&str, (&str, &str)> = HashMap::new();

    for line in lines {
        let (node_name, left_right_nodes) = line.split_once("=").expect("We have a node line");
        let (left, right) = left_right_nodes[2..10]
            .split_once(",")
            .expect("Points to two nodes");

        nodes.insert(node_name.trim(), (left.trim(), right.trim()));
    }

    let starting_count: u64 = 0;
    let starting_node = "AAA";
    let steps_count = traverse_tree(starting_count, starting_node, &directions, &nodes, "ZZZ");

    println!("{}", steps_count); // 16043

    // part 2

    let starting_nodes: Vec<&str> = nodes
        .keys()
        .filter(|x| x.ends_with('A'))
        .map(|x| x.as_ref())
        .collect();

    let cycles: Vec<u64> = starting_nodes
        .iter()
        .map(|x| calculate_cycle(x, &directions, &nodes))
        .collect();

    let mut cycle_count: u64 = 1;

    for cycle in cycles {
        cycle_count = lcm(cycle_count, cycle);
    }

    println!("{:?}", cycle_count); // 15726453850399
}
