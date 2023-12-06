use std::{fmt, fs, str::Lines};

#[derive(Debug, Clone, Copy)]
struct Range {
    start: u64,
    end: u64,
}

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

    fn transform_range(&self, mut range: Range) -> Vec<Range> {
        let mut cleared = false;
        let mut new_ranges: Vec<Range> = Vec::new();

        for range_map in &self.maps {
            if range.start > range_map.end {
                // we're past this map
                continue;
            }

            if range.end < range_map.start {
                // we have no intersection in the map, so we return the original range
                new_ranges.push(range);
                cleared = true;
                break;
            } else if range.end >= range_map.start && range.end < range_map.end {
                // partial intersection
                if range.start < range_map.start {
                    new_ranges.push(Range {
                        start: range.start,
                        end: range_map.start,
                    });
                    new_ranges.push(Range {
                        start: ((range_map.start as i64) + range_map.offset) as u64,
                        end: ((range.end as i64) + range_map.offset) as u64,
                    });
                } else {
                    new_ranges.push(Range {
                        start: ((range.start as i64) + range_map.offset) as u64,
                        end: ((range.end as i64) + range_map.offset) as u64,
                    });
                }
                cleared = true;
                break;
            } else {
                // full intersection
                if range.start < range_map.start {
                    new_ranges.push(Range {
                        start: range.start,
                        end: range_map.start,
                    });
                }
                new_ranges.push(Range {
                    start: ((range.start as i64) + range_map.offset) as u64,
                    end: ((range_map.end as i64) + range_map.offset) as u64,
                });
                // continue mapping with the end bit
                range = Range {
                    start: range_map.end,
                    end: range.end,
                }
            }
        }
        if !cleared {
            new_ranges.push(range);
        }

        return new_ranges
            .into_iter()
            .filter(|x| x.start != x.end)
            .collect::<Vec<_>>();
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
        fs::read_to_string("src/day5/input.txt").expect("Should have been able to read the file");

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

    let seeds_2: Vec<Range> = seeds
        .iter()
        .array_chunks::<2>()
        .map(|x| Range {
            start: *x[0],
            end: *x[0] + x[1],
        })
        .collect();

    let location_2: Option<Range> = seeds_2
        .iter()
        .map(|seed_range| seed_to_soil.transform_range(*seed_range))
        .flatten()
        .map(|soil_range: Range| soil_to_fertilizer.transform_range(soil_range))
        .flatten()
        .map(|fertilizer_range: Range| fertilizer_to_water.transform_range(fertilizer_range))
        .flatten()
        .map(|water_range| water_to_light.transform_range(water_range))
        .flatten()
        .map(|light_range| light_to_temperature.transform_range(light_range))
        .flatten()
        .map(|temperature_range| temperature_to_humidity.transform_range(temperature_range))
        .flatten()
        .map(|humidity_range| humidity_to_location.transform_range(humidity_range))
        .flatten()
        .min_by(|a, b| a.start.partial_cmp(&b.start).unwrap());

    println!("{:?}", location_2); // 37806486
}
