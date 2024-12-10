const std = @import("std");
const print = std.debug.print;

const Position = struct {
    x: usize,
    y: usize,
};

fn countOfHikingTrails(grid: [][]u8, pos: Position, elevation: i16, peaks: *std.AutoHashMap(Position, bool)) u64 {
    const current_elevation = grid[pos.y][pos.x];
    if (current_elevation <= elevation) return 0;
    if (current_elevation - elevation > 1) return 0;
    if (current_elevation == 9) {
        // part 1
        // if (peaks.contains(pos)) return 0;
        // peaks.put(pos, true) catch unreachable;
        return 1;
    }

    var result: u64 = 0;
    if (pos.x + 1 < grid[0].len) {
        result += countOfHikingTrails(grid, Position{ .x = pos.x + 1, .y = pos.y }, current_elevation, peaks);
    }
    if (pos.x >= 1) {
        result += countOfHikingTrails(grid, Position{ .x = pos.x - 1, .y = pos.y }, current_elevation, peaks);
    }
    if (pos.y + 1 < grid.len) {
        result += countOfHikingTrails(grid, Position{ .x = pos.x, .y = pos.y + 1 }, current_elevation, peaks);
    }
    if (pos.y >= 1) {
        result += countOfHikingTrails(grid, Position{ .x = pos.x, .y = pos.y - 1 }, current_elevation, peaks);
    }
    return result;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input_file = @embedFile("input.txt");

    // setup grid
    var grid = std.ArrayList([]u8).init(allocator);
    defer grid.deinit();

    var starting_positions = std.ArrayList(Position).init(allocator);
    defer starting_positions.deinit();

    // load grid
    var it = std.mem.tokenizeScalar(u8, input_file, '\n');
    var y: usize = 0;
    while (it.next()) |line| {
        const row = try allocator.alloc(u8, line.len);
        for (line, 0..) |c, x| {
            row[x] = c - '0';
            if (row[x] == 0) {
                try starting_positions.append(Position{ .x = x, .y = y });
            }
        }
        try grid.append(row);
        y += 1;
    }

    var result: u64 = 0;
    for (starting_positions.items) |pos| {
        var peaks = std.AutoHashMap(Position, bool).init(allocator);
        defer peaks.deinit();
        const score = countOfHikingTrails(grid.items, pos, -1, &peaks);
        result += score;
    }
    // part 1 - 629
    // part 2 - 1242
    print("{d}\n", .{result});
}
