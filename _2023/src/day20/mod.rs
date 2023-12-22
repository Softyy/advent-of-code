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

    fn receive(&mut self, pulse: Pulse) -> Pulse {
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

    fn receive(&mut self, sender: &str, pulse: Pulse) -> Pulse {
        self.inputs
            .entry(sender.to_string())
            .and_modify(|p| *p = pulse)
            .or_insert(Pulse::Low);

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
        fs::read_to_string("src/day20/test.txt").expect("Should have been able to read the file");

    let regex = Regex::new(r"(?<input>.+) -> (?<outputs>.+)").unwrap();

    let mut map: HashMap<String, Node> = HashMap::new();
    let mut root: Vec<String> = Vec::new();

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
            map.entry(input[1..].to_string())
                .or_insert(Node::Conjunction(conj));
        } else if input.starts_with('%') {
            let flip_flop = FlipFlop::new(outputs);
            map.entry(input[1..].to_string())
                .or_insert(Node::FlipFlop(flip_flop));
        } else {
            root = outputs;
        }
    }

    let mut low_pulses = root.len();
    let mut high_pulses = 0;

    println!("{:?}", map);
    for _ in 0..1 {
        // press the broadcast button
        let mut pulse_queue: VecDeque<(String, String, Pulse)> = VecDeque::from_iter(
            izip!(
                vec!["broadcaster".to_string(); root.len()],
                root.clone(),
                vec![Pulse::Low; root.len()]
            )
            .rev(),
        );

        // println!("{:?}", pulse_queue);

        // now we have the queue, we go until it's empty.
        while let Some((sender, reciever, pulse)) = pulse_queue.pop_back() {
            println!("{:?}", pulse_queue);

            map.entry(reciever.clone()).and_modify(|n| {
                println!("{:?} {:?} {:?}", sender, reciever, pulse);

                match n {
                    Node::Conjunction(conj) => match conj.receive(&sender, pulse) {
                        Pulse::High => {
                            for output in conj.outputs.iter() {
                                high_pulses += 1;
                                if !pulse_queue.iter().any(|(_, node, _)| node == &reciever) {
                                    pulse_queue.push_front((
                                        reciever.clone(),
                                        output.to_string(),
                                        Pulse::High,
                                    ));
                                }
                            }
                        }
                        Pulse::Low => {
                            for output in conj.outputs.iter() {
                                low_pulses += 1;
                                // if !pulse_queue.iter().any(|(_, node, _)| node == &reciever) {
                                pulse_queue.push_front((
                                    reciever.clone(),
                                    output.to_string(),
                                    Pulse::Low,
                                ));
                                // }
                            }
                        }
                        _ => {}
                    },

                    Node::FlipFlop(ff) => match ff.receive(Pulse::Low) {
                        Pulse::High => {
                            for output in ff.outputs.iter() {
                                high_pulses += 1;
                                // if !pulse_queue.iter().any(|(_, node, _)| node == &reciever) {
                                pulse_queue.push_front((
                                    reciever.clone(),
                                    output.to_string(),
                                    Pulse::High,
                                ));
                                // }
                            }
                        }
                        Pulse::Low => {
                            for output in ff.outputs.iter() {
                                low_pulses += 1;
                                // if !pulse_queue.iter().any(|(_, node, _)| node == &reciever) {
                                pulse_queue.push_front((
                                    reciever.clone(),
                                    output.to_string(),
                                    Pulse::Low,
                                ));
                                // }
                            }
                        }
                        _ => {}
                    },
                }
            });
        }
    }

    println!("{:?}", high_pulses * low_pulses)
}
