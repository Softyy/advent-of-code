pub fn transpose<T>(v: Vec<Vec<T>>) -> Vec<Vec<T>> {
    assert!(!v.is_empty());
    let len = v[0].len();
    let mut iters: Vec<_> = v.into_iter().map(|n| n.into_iter()).collect();
    (0..len)
        .map(|_| {
            iters
                .iter_mut()
                .map(|n| n.next().unwrap())
                .collect::<Vec<T>>()
        })
        .collect()
}

// ref: https://en.wikipedia.org/wiki/A*_search_algorithm

// #[derive(Debug, Clone, Hash, PartialEq, Eq)]
// struct Point {
//     row: usize,
//     col: usize,
// }

// #[derive(Debug, PartialEq, Eq)]
// struct OrderedPoint {
//     loc: Point,
//     value: u32,
// }

// impl PartialOrd for OrderedPoint {
//     fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
//         Some(self.value.cmp(&other.value).reverse())
//     }
// }

// impl Ord for OrderedPoint {
//     fn cmp(&self, other: &Self) -> Ordering {
//         self.value.partial_cmp(&other.value).unwrap()
//     }
// }

// fn reconstruct_path(came_from: &HashMap<Point, Point>, mut current: &Point) -> Vec<Point> {
//     let mut total_path = vec![current.clone()];
//     loop {
//         match came_from.get(&current) {
//             Some(node) => {
//                 current = node;
//                 total_path.push(current.clone());
//             }
//             None => break,
//         }
//     }
//     return total_path;
// }

// pub fn a_star(start: Point, goal: Point, cost: &Vec<Vec<u32>>) -> Vec<Point> {
//     // min-heap (we reverse in the Ord in OrderedPoint )
//     let mut open_set: BinaryHeap<OrderedPoint> = BinaryHeap::from([ OrderedPoint { loc: start, value:0 }]);

//     // For node n, cameFrom[n] is the node immediately preceding it on the cheapest path from the start
//     // to n currently known.
//     let mut came_from: HashMap<Point, Point> = HashMap::new();

//     // For node n, gScore[n] is the cost of the cheapest path from start to n currently known.
//     let mut g_score: HashMap<Point, u32> = HashMap::new();
//     g_score.insert(start, 0);

//     while !open_set.is_empty() {
//         // This operation can occur in O(Log(N)) time if openSet is a min-heap or a priority queue
//         let current: OrderedPoint = open_set.pop().expect("Heap is not empty");
//         if current.loc == goal {
//             return reconstruct_path(&came_from, &goal);
//         }

//         for each neighbor of current
//             // d(current,neighbor) is the weight of the edge from current to neighbor
//             // tentative_gScore is the distance from start to the neighbor through current
//             let tentative_g_score :u32= g_score[current.loc] + h[neighbour.row][neighbour.col];

//             if tentative_g_score < g_score.get(&neighbor).unwrap_or(u32::Max) {
//                 // This path to neighbor is better than any previous one. Record it!
//                 came_from.insert(neighbor, current);
//                 g_score.insert(neighbor,tentative_g_score);
//                 // fScore[neighbor] := tentative_gScore + h(neighbor)
//                 if !open_set.contains_key(neighbor) {
//                     open_set.add(neighbor)
//                 }
//             }
//     }

//     panic!("open_set is empty but goal was never reached")
// }
