use std::fs;

struct Race {
    time: u64,
    dist: u64,
}

impl Race {
    fn win(&self, dist: u64) -> bool {
        return dist >= self.dist;
    }

    fn winning_times(&self) -> Vec<u64> {
        let mut times: Vec<u64> = Vec::new();
        for button_time in 0..self.time {
            let race_time = self.time - button_time;
            let dist = button_time * race_time;
            if self.win(dist) {
                times.push(button_time);
            }
        }
        return times;
    }

    fn winning_ways_count(&self) -> u64 {
        return self.winning_times().len() as u64;
    }
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day6/input.txt").expect("Should have been able to read the file");
    let mut lines: std::str::Lines<'_> = contents.lines();

    let times: Vec<u64> = lines.next().expect("Time: <numbers>")[5..]
        .split_whitespace()
        .map(|x| x.parse::<u64>().expect("number should be u64"))
        .collect();

    let mut dists: Vec<u64> = lines.next().expect("Distance: <numbers>")[9..]
        .split_whitespace()
        .map(|x| x.parse::<u64>().expect("number should be u64"))
        .collect();

    let mut races: Vec<Race> = Vec::new();

    for (time, dist) in times.iter().zip(dists.iter_mut()) {
        races.push(Race {
            time: *time,
            dist: *dist,
        })
    }

    let mutiply_counts = races
        .iter()
        .map(|race| race.winning_ways_count())
        .reduce(|a, b| a * b)
        .expect("a u64");

    println!("{}", mutiply_counts); // 275724

    // part 2

    let contents_2: String =
        fs::read_to_string("src/day6/input.txt").expect("Should have been able to read the file");
    let mut lines_2: std::str::Lines<'_> = contents_2.lines();

    let time: u64 = lines_2.next().expect("Time: <numbers>")[5..]
        .chars()
        .filter(|c| !c.is_whitespace())
        .collect::<String>()
        .parse::<u64>()
        .expect("number should be i32");

    let dist: u64 = lines_2.next().expect("Distance: <numbers>")[9..]
        .chars()
        .filter(|c| !c.is_whitespace())
        .collect::<String>()
        .parse::<u64>()
        .expect("number should be i32");

    let long_race = Race {
        time: time,
        dist: dist,
    };

    println!("{}", long_race.winning_ways_count()); // 37286485
}
