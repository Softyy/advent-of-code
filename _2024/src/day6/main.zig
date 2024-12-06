const std = @import("std");
const print = std.debug.print;

const Direction = enum {
    N,
    E,
    S,
    W,
    pub fn turn(self: Direction) Direction {
        return switch (self) {
            Direction.N => Direction.E,
            Direction.E => Direction.S,
            Direction.S => Direction.W,
            Direction.W => Direction.N,
        };
    }
};

const Position = struct {
    x: usize,
    y: usize,
};

const Guard = struct {
    pos: Position,
    dir: Direction,
};

fn isObstruction(grid: [][]u8, pos: Position) bool {
    return grid[pos.y][pos.x] == '#';
}

fn inBounds(pos: Position, width: usize, height: usize) bool {
    return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("src/day6/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var grid = std.ArrayList([]u8).init(allocator);
    defer grid.deinit();

    var guard: Guard = undefined;
    var seen = std.AutoHashMap(Position, bool).init(allocator);
    var seen_count: u32 = 0;

    // load grid
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_copy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, line_copy, line);
        try grid.append(line_copy);
    }

    const height = grid.items.len;
    const width = grid.items[0].len;

    // get starting location.
    locSearch: for (0..height) |y| {
        for (0..width) |x| {
            if (grid.items[y][x] == '^') {
                const pos = Position{ .x = x, .y = y };
                guard = Guard{ .pos = pos, .dir = Direction.N };
                try seen.put(pos, true);
                seen_count += 1;
                break :locSearch;
            }
        }
    }
    // start walking
    while (true) {
        // move in guard direction
        const next_pos = switch (guard.dir) {
            Direction.N => Position{ .x = guard.pos.x, .y = guard.pos.y - 1 },
            Direction.S => Position{ .x = guard.pos.x, .y = guard.pos.y + 1 },
            Direction.E => Position{ .x = guard.pos.x + 1, .y = guard.pos.y },
            Direction.W => Position{ .x = guard.pos.x - 1, .y = guard.pos.y },
        };

        if (!inBounds(next_pos, width, height)) {
            // we're out
            break;
        }
        if (isObstruction(grid.items, next_pos)) {
            // we're going to hit something. TURN!
            guard.dir = guard.dir.turn();
        } else {
            guard.pos = next_pos;
            const _seen = try seen.getOrPut(next_pos);
            if (!_seen.found_existing) {
                _seen.value_ptr.* = true;
                seen_count += 1;
            }
        }
    }

    // part 1 - 4964
    print("{d}\n", .{seen_count});
}
