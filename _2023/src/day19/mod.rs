use std::{collections::HashMap, fs, ops::Bound};

use regex::Regex;

#[derive(Debug)]
struct Part {
    x: u32,
    m: u32,
    a: u32,
    s: u32,
}
impl Part {
    fn get(&self, prop_char: char) -> u32 {
        match prop_char {
            'x' => self.x,
            'm' => self.m,
            'a' => self.a,
            's' => self.s,
            _ => unreachable!(),
        }
    }

    fn value(&self) -> u32 {
        return self.x + self.m + self.a + self.s;
    }
}

#[derive(Debug)]
struct Bounds {
    start: u32,
    end: u32,
}

impl Bounds {
    fn new() -> Self {
        Self {
            start: 0,
            end: u32::MAX,
        }
    }
}

#[derive(Debug)]
struct GenericPart {
    x: Bounds,
    m: Bounds,
    a: Bounds,
    s: Bounds,
}

impl GenericPart {
    fn new() -> Self {
        Self {
            x: Bounds::new(),
            m: Bounds::new(),
            a: Bounds::new(),
            s: Bounds::new(),
        }
    }
}

#[derive(Debug, Clone, Copy)]
enum Comparison {
    GT,
    LT,
    None,
}

#[derive(Debug, Clone)]
struct Condition {
    key: char,
    cmp: Comparison,
    value: u32,
    dest: String,
}

impl Condition {
    fn goto(dest: &str) -> Self {
        Self {
            key: '_',
            value: 0,
            cmp: Comparison::None,
            dest: dest.to_string(),
        }
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day19/input.txt").expect("Should have been able to read the file");
    let (workflow_data, part_data) = contents
        .split_once("\n\n")
        .expect("input should be splitable");

    let mut workflows_map: HashMap<&str, Vec<Condition>> = HashMap::new();
    let mut parts: Vec<Part> = Vec::new();

    let comp_reg =
        Regex::new(r"(?<lt>(?<key1>.)<(?<value1>[0-9]+))|(?<gt>(?<key2>.)>(?<value2>[0-9]+))")
            .unwrap();
    let cond_reg = Regex::new(r"(?<g1>(?<cond>.+):(?<goto>.+))|(?<g2>.+)").unwrap();
    let workflow_reg = Regex::new(r"(?<name>[a-z]+)\{(?<conds>.+)\}").unwrap();

    for workflow_line in workflow_data.lines() {
        let capture = workflow_reg.captures(workflow_line).expect("should match");
        let workflow_name = &capture.name("name").expect("Should have a name").as_str();
        for condition in capture["conds"].split(',').into_iter() {
            let capture = cond_reg.captures(condition).unwrap();
            if capture.name("g1").is_some() {
                let cond = capture.name("cond").unwrap().as_str();
                let goto = capture.name("goto").unwrap().as_str();

                let capture = comp_reg.captures(cond).unwrap();
                let c = if capture.name("lt").is_some() {
                    Condition {
                        key: capture
                            .name("key1")
                            .unwrap()
                            .as_str()
                            .chars()
                            .into_iter()
                            .next()
                            .unwrap(),
                        cmp: Comparison::LT,
                        value: capture
                            .name("value1")
                            .unwrap()
                            .as_str()
                            .parse::<u32>()
                            .unwrap(),
                        dest: goto.to_string(),
                    }
                } else {
                    Condition {
                        key: capture
                            .name("key2")
                            .unwrap()
                            .as_str()
                            .chars()
                            .into_iter()
                            .next()
                            .unwrap(),
                        cmp: Comparison::GT,
                        value: capture
                            .name("value2")
                            .unwrap()
                            .as_str()
                            .parse::<u32>()
                            .unwrap(),
                        dest: goto.to_string(),
                    }
                };
                workflows_map
                    .entry(workflow_name)
                    .and_modify(|v| v.push(c.clone()))
                    .or_insert(vec![c]);
            } else {
                let dest = capture.name("g2").unwrap().as_str();
                workflows_map
                    .entry(workflow_name)
                    .and_modify(|v| v.push(Condition::goto(dest)))
                    .or_insert(vec![Condition::goto(dest)]);
            }
        }
    }
    let part_reg =
        Regex::new(r"\{x=(?<x>[0-9]+),m=(?<m>[0-9]+),a=(?<a>[0-9]+),s=(?<s>[0-9]+)\}").unwrap();

    for part_line in part_data.lines() {
        let capture = part_reg.captures(part_line).expect("Should capture");
        parts.push(Part {
            x: capture["x"].parse::<u32>().expect("should be a num"),
            m: capture["m"].parse::<u32>().expect("should be a num"),
            a: capture["a"].parse::<u32>().expect("should be a num"),
            s: capture["s"].parse::<u32>().expect("should be a num"),
        });
    }

    let mut accepted_parts: Vec<Part> = Vec::new();
    let mut rejected_parts: Vec<Part> = Vec::new();

    // parts start in the "in" workflow
    for part in parts {
        let mut current_workflow = "in";
        loop {
            if current_workflow == "A" {
                accepted_parts.push(part);
                break;
            } else if current_workflow == "R" {
                rejected_parts.push(part);
                break;
            }

            let workflow = workflows_map
                .get(current_workflow)
                .expect("should should exist");

            // apply conditions

            for cond in workflow {
                match cond.cmp {
                    Comparison::GT => {
                        if part.get(cond.key) > cond.value {
                            current_workflow = &cond.dest;
                            break;
                        }
                    }
                    Comparison::LT => {
                        if part.get(cond.key) < cond.value {
                            current_workflow = &cond.dest;
                            break;
                        }
                    }
                    Comparison::None => current_workflow = &cond.dest,
                }
            }
        }
    }

    println!(
        "{:?}",
        accepted_parts.iter().map(|p| p.value()).sum::<u32>()
    ); // part 446517

    let mut g_part = GenericPart::new();
}
