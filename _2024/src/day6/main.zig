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

    pub fn nextPos(self: Guard, max_x: usize, max_y: usize) ?Position {
        if (self.pos.y == 0 and self.dir == Direction.N) return null;
        if (self.pos.y == max_y and self.dir == Direction.S) return null;
        if (self.pos.x == 0 and self.dir == Direction.W) return null;
        if (self.pos.x == max_x and self.dir == Direction.E) return null;

        return switch (self.dir) {
            Direction.N => Position{ .x = self.pos.x, .y = self.pos.y - 1 },
            Direction.S => Position{ .x = self.pos.x, .y = self.pos.y + 1 },
            Direction.E => Position{ .x = self.pos.x + 1, .y = self.pos.y },
            Direction.W => Position{ .x = self.pos.x - 1, .y = self.pos.y },
        };
    }
};

fn isObstruction(grid: [][]u8, pos: Position) bool {
    return grid[pos.y][pos.x] == '#';
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

    var guard_start: Guard = undefined;
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
                try seen.put(pos, true);
                guard_start = Guard{ .pos = pos, .dir = Direction.N };
                guard = guard_start;
                seen_count += 1;
                break :locSearch;
            }
        }
    }
    // start walking
    while (true) {
        // move in guard direction
        const _next_pos = guard.nextPos(width - 1, height - 1);
        if (_next_pos == null) {
            // we're out
            break;
        }
        const next_pos = _next_pos.?;

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

    var loop_count: u64 = 0;
    var key_iter = seen.keyIterator();
    while (key_iter.next()) |possible_obs| {
        // cannot put an obstacle on the starting position.
        if (std.meta.eql(possible_obs.*, guard_start.pos)) continue;

        grid.items[possible_obs.y][possible_obs.x] = '#';

        guard = guard_start;
        var guard_path = std.AutoHashMap(Guard, bool).init(allocator);
        defer guard_path.deinit();

        while (true) {
            const _next_pos = guard.nextPos(width - 1, height - 1);
            if (_next_pos == null) {
                // we're out
                break;
            }
            const next_pos = _next_pos.?;

            const next_guard = Guard{ .pos = next_pos, .dir = guard.dir };
            if (guard_path.get(next_guard) != null) {
                // we're in a loop
                loop_count += 1;
                break;
            }

            if (isObstruction(grid.items, next_pos)) {
                // we're going to hit something. TURN!
                guard.dir = guard.dir.turn();
            } else {
                guard.pos = next_pos;
            }

            const _path = try guard_path.getOrPut(next_guard);
            if (!_path.found_existing) {
                _path.value_ptr.* = true;
            }
        }

        grid.items[possible_obs.y][possible_obs.x] = '.';
    }

    // part 2 - 1740
    print("{d}\n", .{loop_count});
}
