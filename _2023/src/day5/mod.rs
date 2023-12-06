use std::{
    cmp::{max, min},
    fmt, fs,
    str::Lines,
};

#[derive(Debug, Clone, Copy)]
struct RangeMap {
    start: u64,
    end: u64,
    offset: i64,
}

impl RangeMap {
    fn contains(&self, seed: u64) -> bool {
        return seed >= self.start && seed < self.end;
    }

    fn intersects(&self, range_map: &RangeMap) -> Option<RangeMap> {
        let new_map = RangeMap {
            start: max(range_map.start, self.start),
            end: min(range_map.end, self.end),
            offset: range_map.offset + self.offset,
        };
        return if new_map.end >= new_map.start {
            Some(new_map)
        } else {
            None
        };
    }

    fn bounds(&self) -> (i64, i64) {
        return (
            self.start as i64 + self.offset,
            self.end as i64 + self.offset,
        );
    }
}

impl fmt::Display for RangeMap {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "[{}..{},{}]", self.start, self.end, self.offset)
    }
}

#[derive(Debug)]
struct RangeMaps {
    maps: Vec<RangeMap>,
}

impl RangeMaps {
    fn transform(&self, seed: u64) -> u64 {
        for range_map in &self.maps {
            if range_map.contains(seed) {
                return (seed as i64 + range_map.offset) as u64;
            }
        }

        return seed;
    }

    fn min_transform(&self, start: u64, end: u64) -> u64 {
        let mut maps_which_could_transform: Vec<(i64, i64)> = Vec::new();
        for range_map in &self.maps {
            let new_map = range_map.intersects(&RangeMap {
                start: start,
                end: end,
                offset: 0,
            });
            if new_map.is_some() {
                maps_which_could_transform.push(new_map.unwrap().bounds());
            }
        }
        println!("{:?}", maps_which_could_transform);

        return maps_which_could_transform
            .iter()
            .map(|x| x.0)
            .min()
            .unwrap() as u64;
    }

    fn chain(&self, new_range_maps: RangeMaps) -> RangeMaps {
        let mut new_maps: Vec<RangeMap> = Vec::new();

        let mut s1: Vec<RangeMap> = self.maps.iter().copied().collect();
        let mut s2 = new_range_maps.maps;
        println!("");
        println!("{:?}", s1);
        println!("{:?}", s2);

        loop {
            match (s1.pop(), s2.pop()) {
                (Some(c1), Some(c2)) => {
                    if c1.end < c2.start {
                        // no intersection
                        new_maps.push(c1);
                        s2.push(c2) // put it back
                    } else if c1.end < c2.end {
                        //partial inersection
                        new_maps.push(RangeMap {
                            start: c1.start,
                            end: c2.start,
                            offset: c1.offset,
                        });
                        new_maps.push(RangeMap {
                            start: c2.start,
                            end: c1.end,
                            offset: c1.offset + c2.offset,
                        });
                        s2.push(RangeMap {
                            start: c1.end,
                            end: c2.end,
                            offset: c2.offset,
                        })
                    } else {
                        // full intersection
                        new_maps.push(RangeMap {
                            start: c1.start,
                            end: c2.start,
                            offset: c1.offset,
                        });
                        new_maps.push(RangeMap {
                            start: c2.start,
                            end: c2.end,
                            offset: c1.offset + c2.offset,
                        });
                        s1.push(RangeMap {
                            start: c2.end,
                            end: c1.end,
                            offset: c1.offset,
                        })
                    }
                }
                (Some(c1), None) => {
                    new_maps.push(c1);
                }
                (None, Some(c2)) => {
                    new_maps.push(c2);
                }
                _ => {
                    break;
                }
            }
        }
        new_maps.sort_by(|a, b| a.start.partial_cmp(&b.start).unwrap());

        return RangeMaps { maps: new_maps };
    }
}

fn parse_input(lines: &mut Lines<'_>) -> RangeMaps {
    lines.next();
    let mut range_maps = RangeMaps { maps: Vec::new() };
    while let Some(row) = lines.next() {
        if row.is_empty() {
            break;
        }
        let mut items = row
            .split_whitespace()
            .map(|x| x.parse::<u64>().expect("u64 should be here"));
        let destination_range_start = items.next().unwrap();
        let source_range_start = items.next().unwrap();
        let range_length = items.next().unwrap();

        let map = RangeMap {
            start: source_range_start,
            end: source_range_start + range_length,
            offset: destination_range_start as i64 - source_range_start as i64,
        };
        range_maps.maps.push(map);
    }
    range_maps
        .maps
        .sort_by(|a, b| a.start.partial_cmp(&b.start).unwrap());

    return range_maps;
}

pub fn main() {
    let contents: String =
        fs::read_to_string("src/day5/test.txt").expect("Should have been able to read the file");

    let mut lines = contents.lines();

    let seeds: Vec<u64> = lines.next().expect("seeds")[6..]
        .split_whitespace()
        .map(|x| x.parse::<u64>().expect("u32 should be here"))
        .collect();

    lines.next();

    let seed_to_soil = parse_input(&mut lines);
    let soil_to_fertilizer = parse_input(&mut lines);
    let fertilizer_to_water = parse_input(&mut lines);
    let water_to_light = parse_input(&mut lines);
    let light_to_temperature = parse_input(&mut lines);
    let temperature_to_humidity = parse_input(&mut lines);
    let humidity_to_location = parse_input(&mut lines);

    let location = seeds
        .iter()
        .map(|seed| seed_to_soil.transform(*seed))
        .map(|soil| soil_to_fertilizer.transform(soil))
        .map(|fertilizer| fertilizer_to_water.transform(fertilizer))
        .map(|water| water_to_light.transform(water))
        .map(|light| light_to_temperature.transform(light))
        .map(|temperature| temperature_to_humidity.transform(temperature))
        .map(|humidity| humidity_to_location.transform(humidity))
        .min();

    println!("{}", location.expect("we have an answer"));

    // part 2;

    let seed_to_location = seed_to_soil
        .chain(soil_to_fertilizer)
        .chain(fertilizer_to_water)
        .chain(water_to_light)
        .chain(light_to_temperature)
        .chain(temperature_to_humidity)
        .chain(humidity_to_location);

    let seeds_2: Vec<[&u64; 2]> = seeds.iter().array_chunks::<2>().collect();

    let mut locations: Vec<u64> = Vec::new();

    for seed_info in seeds_2 {
        let seed_range_start = *seed_info[0];
        let range_length = *seed_info[1];
        let seed_range_end = seed_range_start + range_length;
        let min_seed = seed_to_location.min_transform(seed_range_start, seed_range_end);
        locations.push(min_seed);
    }

    println!("{:?}", locations.iter().min());
    println!("{:?}", seed_to_location.transform(82));
}
