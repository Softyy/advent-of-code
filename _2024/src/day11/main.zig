const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

fn setOrInc(key: std.AutoHashMap(u64, u64).GetOrPutResult, inc: u64) void {
    if (key.found_existing) {
        key.value_ptr.* += inc;
    } else {
        key.value_ptr.* = inc;
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input_file = @embedFile("input.txt");

    // setup buckets
    var buckets = std.AutoHashMap(u64, u64).init(allocator);
    defer buckets.deinit();

    // load grid
    var it = std.mem.tokenizeScalar(u8, input_file, ' ');
    while (it.next()) |line| {
        const stone = try std.fmt.parseInt(u64, line, 10);
        const key = try buckets.getOrPut(stone);
        setOrInc(key, 1);
    }

    const number_of_blinks: usize = 75;

    for (0..number_of_blinks) |_| {
        var key_it = buckets.keyIterator();
        var next_buckets = std.AutoHashMap(u64, u64).init(allocator);
        while (key_it.next()) |key| {
            const stone = key.*;
            const multiplier = buckets.get(stone).?;

            if (stone == 0) {
                const next_key = try next_buckets.getOrPut(1);
                setOrInc(next_key, multiplier);
                continue;
            }

            var buffer: [40]u8 = undefined; // Buffer large enough to hold the a u64
            const stone_str = std.fmt.bufPrint(&buffer, "{d}", .{stone}) catch unreachable;
            if (stone_str.len % 2 == 0) {
                const left_stone = try parseInt(u64, stone_str[0 .. stone_str.len / 2], 10);
                const right_stone = try parseInt(u64, stone_str[stone_str.len / 2 ..], 10);

                const next_left_key = try next_buckets.getOrPut(left_stone);
                setOrInc(next_left_key, multiplier);

                const next_right_key = try next_buckets.getOrPut(right_stone);
                setOrInc(next_right_key, multiplier);
                continue;
            }

            const next_key = try next_buckets.getOrPut(stone * 2024);
            setOrInc(next_key, multiplier);
        }

        buckets = next_buckets;
    }

    var value_it = buckets.valueIterator();
    var result: u64 = 0;

    while (value_it.next()) |count| {
        result += count.*;
    }
    // part 1 - 183248
    // part 2 - 218811774248729
    print("{d}\n", .{result});
}
