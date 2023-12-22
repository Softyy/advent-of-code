use core::panic;
use std::{
    collections::{HashMap, VecDeque},
    fs,
    iter::zip,
};

use itertools::izip;
use regex::Regex;

#[derive(Debug, PartialEq, Eq, Clone)]
enum Pulse {
    High,
    Low,
    None,
}

#[derive(Debug)]
struct FlipFlop {
    state: bool, // false=off , true=on
    outputs: Vec<String>,
}

impl FlipFlop {
    fn new(outputs: Vec<String>) -> Self {
        Self {
            state: false,
            outputs,
        }
    }

    fn receive(&mut self, pulse: &Pulse) -> Pulse {
        match pulse {
            Pulse::Low => {
                self.state = !self.state;
                if self.state {
                    Pulse::High
                } else {
                    Pulse::Low
                }
            }
            _ => Pulse::None,
        }
    }
}

#[derive(Debug)]
struct Conjunction {
    inputs: HashMap<String, Pulse>,
    outputs: Vec<String>,
}

impl Conjunction {
    fn new(outputs: Vec<String>) -> Self {
        Self {
            inputs: HashMap::new(),
            outputs,
        }
    }

    fn receive(&mut self, sender: &str, pulse: &Pulse) -> Pulse {
        self.inputs
            .entry(sender.to_string())
            .and_modify(|p: &mut Pulse| *p = pulse.clone())
            .or_insert(pulse.clone());

        if self.inputs.values().all(|p| *p == Pulse::High) {
            Pulse::Low
        } else {
            Pulse::High
        }
    }
}

#[derive(Debug)]
enum Node {
    Conjunction(Conjunction),
    FlipFlop(FlipFlop),
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day20/input.txt").expect("Should have been able to read the file");

    let regex = Regex::new(r"(?<input>.+) -> (?<outputs>.+)").unwrap();

    let mut map: HashMap<String, Node> = HashMap::new();
    let mut root: Vec<String> = Vec::new();

    let mut conj_nodes: Vec<String> = Vec::new();

    for line in contents.lines() {
        let capture = regex.captures(line).unwrap();

        let input = capture.name("input").unwrap().as_str();
        let outputs: Vec<String> = capture
            .name("outputs")
            .unwrap()
            .as_str()
            .split(",")
            .map(|s| s.trim().to_string())
            .collect();

        if input.starts_with('&') {
            let conj = Conjunction::new(outputs);
            conj_nodes.push(input[1..].to_string());
            map.entry(input[1..].to_string())
                .or_insert(Node::Conjunction(conj));
        } else if input.starts_with('%') {
            let flip_flop = FlipFlop::new(outputs);
            map.entry(input[1..].to_string())
                .or_insert(Node::FlipFlop(flip_flop));
        } else {
            root = outputs;
        }

        // set the inputs on all conj nodes
        for conj_node_name in conj_nodes.iter() {
            let mut inputs: Vec<String> = Vec::new();
            for node_name in map.keys() {
                match map.get(node_name) {
                    Some(Node::Conjunction(conj)) => {
                        if conj.outputs.contains(conj_node_name) {
                            inputs.push(node_name.to_string())
                        }
                    }
                    Some(Node::FlipFlop(ff)) => {
                        if ff.outputs.contains(conj_node_name) {
                            inputs.push(node_name.to_string())
                        }
                    }
                    _ => unreachable!(),
                }
            }
            map.entry(conj_node_name.to_string())
                .and_modify(|n| match n {
                    Node::Conjunction(conj) => {
                        for input in inputs {
                            conj.receive(&input, &Pulse::Low);
                        }
                    }
                    _ => {}
                });
        }
    }

    let mut low_pulses: u64 = 0;
    let mut high_pulses: u64 = 0;

    for button_presses in 0..100000000 {
        // press the broadcast button
        low_pulses += 1; // start with 1 from button
        let mut pulse_queue: VecDeque<(String, String, Pulse)> = VecDeque::from_iter(
            izip!(
                vec!["broadcaster".to_string(); root.len()],
                root.clone(),
                vec![Pulse::Low; root.len()]
            )
            .rev(),
        );

        // now we have the queue, we go until it's empty.

        while let Some((sender, reciever, pulse)) = pulse_queue.pop_back() {
            match pulse {
                Pulse::Low => low_pulses += 1,
                Pulse::High => high_pulses += 1,
                _ => {}
            }

            // part 2, early return
            if reciever == "rx" && pulse == Pulse::Low {
                println!("{}", button_presses + 1);
                break;
            }

            map.entry(reciever.clone()).and_modify(|n| {
                // println!("{:?} {:?} {:?}", sender, reciever, pulse);
                match n {
                    Node::Conjunction(conj) => match conj.receive(&sender, &pulse) {
                        Pulse::High => {
                            for output in conj.outputs.iter() {
                                pulse_queue.push_front((
                                    reciever.clone(),
                                    output.to_string(),
                                    Pulse::High,
                                ));
                            }
                        }
                        Pulse::Low => {
                            for output in conj.outputs.iter() {
                                pulse_queue.push_front((
                                    reciever.clone(),
                                    output.to_string(),
                                    Pulse::Low,
                                ));
                            }
                        }
                        _ => unreachable!(),
                    },

                    Node::FlipFlop(ff) => match ff.receive(&pulse) {
                        Pulse::High => {
                            for output in ff.outputs.iter() {
                                pulse_queue.push_front((
                                    reciever.clone(),
                                    output.to_string(),
                                    Pulse::High,
                                ));
                            }
                        }
                        Pulse::Low => {
                            for output in ff.outputs.iter() {
                                pulse_queue.push_front((
                                    reciever.clone(),
                                    output.to_string(),
                                    Pulse::Low,
                                ));
                            }
                        }
                        _ => {}
                    },
                }
            });
        }
    }
    println!("{:?} {:?}", high_pulses, low_pulses);
    // println!("{:?}", high_pulses * low_pulses); // part 1: 839775244
}
