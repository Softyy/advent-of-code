use core::panic;
use std::{cmp::Ordering, collections::HashMap, fs};

#[derive(PartialOrd, Ord, PartialEq, Eq)]
enum HandType {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
}

#[derive(Debug, Eq)]
struct Player {
    bid: u32,
    hand: HashMap<char, u32>,
    cards: String,
}

impl Player {
    fn hand_type(&self) -> HandType {
        match self.hand.keys().count() {
            5 => HandType::HighCard,
            4 => HandType::OnePair,
            3 => {
                if *self.hand.values().max().unwrap() == 3 {
                    HandType::ThreeOfAKind
                } else {
                    HandType::TwoPair
                }
            }
            2 => {
                if *self.hand.values().max().unwrap() == 4 {
                    HandType::FourOfAKind
                } else {
                    HandType::FullHouse
                }
            }
            1 => HandType::FiveOfAKind,
            _ => panic!("We should have at least 5 cards!"),
        }
    }
}

impl Ord for Player {
    fn cmp(&self, other: &Self) -> Ordering {
        let card_values: HashMap<char, u32> = HashMap::from([
            ('2', 1),
            ('3', 2),
            ('4', 3),
            ('5', 4),
            ('6', 5),
            ('7', 6),
            ('8', 7),
            ('9', 8),
            ('T', 9),
            ('J', 0), // part 2
            // ('J', 10), // part 1
            ('Q', 11),
            ('K', 12),
            ('A', 13),
        ]);
        let hand_type = self.hand_type();
        let other_hand_type = other.hand_type();
        if hand_type != other_hand_type {
            return hand_type.cmp(&other_hand_type);
        } else {
            for (card, other_card) in self.cards.chars().zip(other.cards.chars()) {
                let a = *card_values.get(&card).expect("casts");
                let b = *card_values.get(&other_card).expect("casts");
                if a != b {
                    return a.cmp(&b);
                }
            }
        }
        panic!("we should have cards in the player hands")
    }
}

impl PartialOrd for Player {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl PartialEq for Player {
    fn eq(&self, other: &Self) -> bool {
        self.hand == other.hand
    }
}

fn parse_line(line: &str) -> Player {
    let Some((hand_str, bid)) = line.split_once(" ") else {
        panic!("I should have a line")
    };
    let mut hand: HashMap<char, u32> = HashMap::new();

    for char in hand_str.chars() {
        hand.entry(char).and_modify(|x| *x += 1).or_insert(1);
    }

    // part 2 : joker override.
    if hand.contains_key(&'J') {
        let jokers: u32 = *hand.get(&'J').expect("we should have jokers");
        hand.remove(&'J');
        // add to the highest value count
        let best_card = hand
            .iter()
            .max_by(|a, b| a.1.cmp(&b.1))
            .map(|(k, _v)| k)
            .unwrap_or(&'A');

        hand.entry(*best_card)
            .and_modify(|x| *x += jokers)
            .or_insert(jokers);
    }

    // end part 2

    return Player {
        bid: bid.parse::<u32>().expect("u32 should be here"),
        hand,
        cards: hand_str.to_string(),
    };
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day7/input.txt").expect("Should have been able to read the file");

    let mut players: Vec<Player> = contents.lines().map(parse_line).collect();

    players.sort();

    let mut score = 0;

    for (idx, player) in players.iter().enumerate() {
        score += (idx + 1) as u32 * player.bid;
    }

    println!("{:?}", score); // part 1: 248569531, part 2: 250382098
}
