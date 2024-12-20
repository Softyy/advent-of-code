const std = @import("std");
const print = std.debug.print;
const indexOf = std.mem.indexOf;

const Pos = struct {
    x: usize,
    y: usize,

    pub fn N(self: Pos) Pos {
        return Pos{ .x = self.x, .y = self.y - 1 };
    }

    pub fn S(self: Pos) Pos {
        return Pos{ .x = self.x, .y = self.y + 1 };
    }

    pub fn W(self: Pos) Pos {
        return Pos{ .x = self.x - 1, .y = self.y };
    }

    pub fn E(self: Pos) Pos {
        return Pos{ .x = self.x + 1, .y = self.y };
    }

    pub fn eq(self: Pos, other: Pos) bool {
        return self.x == other.x and self.y == other.y;
    }
};
const Wall = std.math.maxInt(u32);

fn updateTimings(next_pos: Pos, last_timing: u32, track: [][]u8, timings: *std.AutoHashMap(Pos, u32)) bool {
    if (!timings.contains(next_pos)) {
        const cell = track[next_pos.y][next_pos.x];
        if (cell == '#') {
            timings.put(next_pos, Wall) catch unreachable;
        } else {
            timings.put(next_pos, last_timing + 1) catch unreachable;
            return true;
        }
    }
    return false;
}

fn cheating(pos: Pos, jump_pos: Pos, jump_dist: u32, timing: *std.AutoHashMap(Pos, u32), cheats: *std.AutoHashMap(u32, u32)) !void {
    const current_timing = timing.get(pos).?;
    if (timing.get(jump_pos)) |jump_timing| {
        if (jump_timing == Wall) return;
        if (jump_timing > current_timing + jump_dist) {
            // shortcut
            const savings = jump_timing - current_timing - jump_dist;
            const key = try cheats.getOrPut(savings);
            if (!key.found_existing) {
                key.value_ptr.* = 0;
            }
            key.value_ptr.* += 1;
        }
    }
}
pub fn main() !void {
    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_alloc.deinit();

    const allocator = arena_alloc.allocator();

    const input_file = @embedFile("input.txt");

    var track = std.ArrayList([]u8).init(allocator);
    var path = std.ArrayList(Pos).init(allocator);

    var timings = std.AutoHashMap(Pos, u32).init(allocator);

    var it = std.mem.splitSequence(u8, input_file, "\n");

    var start: Pos = undefined;
    var end: Pos = undefined;
    var y: usize = 0;
    while (it.next()) |line| {
        if (indexOf(u8, line, "S")) |x| start = Pos{ .x = x, .y = y };
        if (indexOf(u8, line, "E")) |x| end = Pos{ .x = x, .y = y };

        const line_copy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, line_copy, line);
        try track.append(line_copy);
        y += 1;
    }

    var current: Pos = start;

    // map track
    try timings.put(start, 0);
    while (!current.eq(end)) {
        try path.append(current);
        const last_timing = timings.get(current).?;
        var next_pos: Pos = undefined;

        if (updateTimings(current.N(), last_timing, track.items, &timings)) next_pos = current.N();
        if (updateTimings(current.S(), last_timing, track.items, &timings)) next_pos = current.S();
        if (updateTimings(current.W(), last_timing, track.items, &timings)) next_pos = current.W();
        if (updateTimings(current.E(), last_timing, track.items, &timings)) next_pos = current.E();

        current = next_pos;
    }

    var cheats = std.AutoHashMap(u32, u32).init(allocator);

    const cross_size = 20; // = 2 - part 1
    // map hackxsss
    for (path.items) |pos| {
        for (0..(2 * cross_size) + 1) |n| {
            const _dy: i16 = @as(i16, @intCast(n)) - cross_size;

            for (0..(2 * cross_size) + 1) |m| {
                var dy = _dy;
                var dx: i16 = @as(i16, @intCast(m)) - cross_size;
                var jump_pos = pos;
                const jump_dist = @abs(dx) + @abs(dy);

                if (dy > 0 and track.items.len < pos.y + @as(usize, @intCast(dy))) continue;
                if (dx > 0 and track.items[0].len < pos.x + @as(usize, @intCast(dx))) continue;
                if (dy < 0 and pos.y <= -dy) continue;
                if (dx < 0 and pos.x <= -dx) continue;
                if (jump_dist < 2 or jump_dist > cross_size) continue;

                while (dy > 0) {
                    dy -= 1;
                    jump_pos = jump_pos.S();
                }
                while (dx > 0) {
                    dx -= 1;
                    jump_pos = jump_pos.E();
                }
                while (dy < 0) {
                    dy += 1;
                    jump_pos = jump_pos.N();
                }
                while (dx < 0) {
                    dx += 1;
                    jump_pos = jump_pos.W();
                }

                try cheating(pos, jump_pos, jump_dist, &timings, &cheats);
            }
        }
    }

    var p1: u32 = 0;

    var key_it = cheats.keyIterator();

    while (key_it.next()) |savings| {
        const count = cheats.get(savings.*).?;
        if (savings.* < 100) continue;
        // print("{},{}\n", .{ count, savings.* });
        p1 += count;
    }

    // part 1 - 1463
    // part 2 - 985332
    print("Result: {d}\n", .{p1});
}
