use std::fs;

#[derive(Debug)]
struct Card {
    id: i32,
    win_nums: Vec<i32>,
    nums: Vec<i32>,
}

#[derive(Debug)]
struct Score {
    value: i32,
    count: i32,
}

impl Card {
    fn score(&self) -> Score {
        let mut count = 0;
        let mut value = 0;

        for num in &self.nums {
            if self.win_nums.contains(&num) {
                count = count + 1;
                value = if value > 0 { value * 2 } else { 1 }
            }
        }

        return Score {
            value: value,
            count: count,
        };
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day4/input.txt").expect("Should have been able to read the file");
    let lines = contents.lines();
    let mut cards = Vec::new();
    for line in lines {
        let (card_str, numbers_str) = line.split_once(":").expect("valid input");
        let card_id = card_str[5..].trim().parse::<i32>().expect("valid card id");
        let (win_num_str, numbers) = numbers_str.split_once("|").expect("valid input");

        let card = Card {
            id: card_id,
            win_nums: win_num_str
                .split_whitespace()
                .map(|x| x.trim().parse::<i32>().expect("valid i32"))
                .collect(),
            nums: numbers
                .split_whitespace()
                .map(|x| x.trim().parse::<i32>().expect("valid i32"))
                .collect(),
        };

        cards.push(card);
    }

    let score: i32 = cards.iter().map(|x| x.score().value).sum();
    println!("{}", score); // 17803

    // part 2
    // card mania

    let mut scratchcards_count = vec![1; cards.len()];

    for (i, card) in cards.iter().enumerate() {
        let score = card.score();
        if score.count > 0 {
            let base_cards = scratchcards_count[i];
            for j in 1..score.count + 1 {
                scratchcards_count[i + j as usize] += base_cards;
            }
        }
    }
    let total_cards: i32 = scratchcards_count.iter().sum();
    println!("{}", total_cards); // 5554894
}
