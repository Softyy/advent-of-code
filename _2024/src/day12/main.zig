const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const Position = struct {
    x: usize,
    y: usize,
};

fn flood(grid: [][]u8, seen: *std.AutoHashMap(Position, bool), pos: Position) u64 {
    if (seen.contains(pos)) return 0;
    const plot = grid[pos.y][pos.x];
    const area, const perimeter = fill(grid, plot, seen, pos, 0, 0);
    return area * perimeter;
}

fn fill(grid: [][]u8, plot: u8, seen: *std.AutoHashMap(Position, bool), pos: Position, area: u32, perimeter: u32) struct { u32, u32 } {
    const current_plot = grid[pos.y][pos.x];

    if (current_plot != plot) return .{ area, perimeter + 1 };
    if (seen.contains(pos)) return .{ area, perimeter };
    seen.put(pos, true) catch unreachable;

    var _area: u32 = area + 1;
    var _perimeter: u32 = perimeter;

    if (pos.x + 1 < grid[pos.x].len) {
        const a, const p = fill(grid, plot, seen, Position{ .x = pos.x + 1, .y = pos.y }, _area, _perimeter);
        _area = a;
        _perimeter = p;
    } else {
        _perimeter += 1;
    }
    if (pos.x >= 1) {
        const a, const p = fill(grid, plot, seen, Position{ .x = pos.x - 1, .y = pos.y }, _area, _perimeter);
        _area = a;
        _perimeter = p;
    } else {
        _perimeter += 1;
    }
    if (pos.y + 1 < grid.len) {
        const a, const p = fill(grid, plot, seen, Position{ .x = pos.x, .y = pos.y + 1 }, _area, _perimeter);
        _area = a;
        _perimeter = p;
    } else {
        _perimeter += 1;
    }
    if (pos.y >= 1) {
        const a, const p = fill(grid, plot, seen, Position{ .x = pos.x, .y = pos.y - 1 }, _area, _perimeter);
        _area = a;
        _perimeter = p;
    } else {
        _perimeter += 1;
    }
    return .{ _area, _perimeter };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input_file = @embedFile("input.txt");

    // setup grid;
    var grid = std.ArrayList([]u8).init(allocator);
    defer grid.deinit();

    // load grid
    var it = std.mem.tokenizeScalar(u8, input_file, '\n');
    while (it.next()) |line| {
        const line_copy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, line_copy, line);
        try grid.append(line_copy);
    }

    var scores = std.AutoHashMap(u8, u64).init(allocator);
    defer scores.deinit();

    var seen = std.AutoHashMap(Position, bool).init(std.heap.page_allocator);
    defer seen.deinit();

    for (0..grid.items.len) |y| {
        for (0..grid.items[y].len) |x| {
            const plot = grid.items[y][x];
            const score = flood(grid.items, &seen, Position{ .x = x, .y = y });
            const key = try scores.getOrPut(plot);
            if (key.found_existing) {
                key.value_ptr.* += score;
            } else {
                key.value_ptr.* = score;
            }
        }
    }

    var result: u64 = 0;

    var values_it = scores.valueIterator();
    while (values_it.next()) |score| {
        result += score.*;
    }

    // part 1 - 1344578
    // part 2 -
    print("{d}\n", .{result});
}
