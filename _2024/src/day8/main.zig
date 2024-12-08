const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const splitScalar = std.mem.splitScalar;

const Position = struct {
    x: i32,
    y: i32,
};

const PositionTuple = struct {
    a: Position,
    b: Position,
};

const Antenna = struct {
    type: u8,
    pos: Position,

    fn antinodes(self: Antenna, other: Antenna, multiple: u16) PositionTuple {
        const dx = self.pos.x - other.pos.x;
        const dy = self.pos.y - other.pos.y;
        return PositionTuple{
            .a = Position{ .x = self.pos.x + (dx * multiple), .y = self.pos.y + (dy * multiple) },
            .b = Position{ .x = other.pos.x - (dx * multiple), .y = other.pos.y - (dy * multiple) },
        };
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("src/day8/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var antennas = std.AutoHashMap(u8, std.ArrayList(Antenna)).init(allocator);

    var max_y: usize = 0;
    var max_x: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        max_x = line.len;
        for (line, 0..line.len) |c, x| {
            if (c == '.') continue;
            const antenna = Antenna{ .type = c, .pos = Position{ .x = @intCast(x), .y = @intCast(max_y) } };
            const _antennasOfType = try antennas.getOrPut(antenna.type);
            if (!_antennasOfType.found_existing) {
                _antennasOfType.value_ptr.* = std.ArrayList(Antenna).init(allocator);
            }
            try _antennasOfType.value_ptr.*.append(antenna);
        }
        max_y += 1;
    }

    var antinodes = std.AutoHashMap(Position, bool).init(allocator);

    var it = antennas.iterator();
    while (it.next()) |antennasOfType| {
        const _antennas = antennasOfType.value_ptr.*;
        for (0.._antennas.items.len - 1) |n| {
            for (n + 1.._antennas.items.len) |m| {
                inline for (0..40) |a| {
                    const _antinodes = _antennas.items[n].antinodes(_antennas.items[m], a);
                    try antinodes.put(_antinodes.a, true);
                    try antinodes.put(_antinodes.b, true);
                }
            }
        }
    }

    var result: usize = 0;
    var antinode_it = antinodes.keyIterator();
    while (antinode_it.next()) |pos| {
        if (pos.x >= 0 and pos.x < max_x and pos.y >= 0 and pos.y < max_y) {
            result += 1;
        }
    }

    // part 1 - 289
    // part 2 - 1030
    print("{d}\n", .{result});
}
