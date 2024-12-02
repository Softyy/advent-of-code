const std = @import("std");
const Order = std.math.Order;
const assert = std.debug.assert;

fn lessThan(context: void, a: u32, b: u32) Order {
    _ = context;
    return std.math.order(a, b);
}

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("src/day1/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var diff_total: u64 = 0;
    var map_total: u64 = 0;

    var left_heap = std.PriorityQueue(u32, void, lessThan).init(std.heap.page_allocator, {});
    defer left_heap.deinit();
    var right_heap = std.PriorityQueue(u32, void, lessThan).init(std.heap.page_allocator, {});
    defer right_heap.deinit();
    var right_hash_map = std.AutoHashMap(u32, u16).init(std.heap.page_allocator);
    defer right_hash_map.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitSequence(u8, line, "   ");

        const left = try std.fmt.parseInt(u32, it.next().?, 10);
        try left_heap.add(left);

        const right = try std.fmt.parseInt(u32, it.next().?, 10);
        try right_heap.add(right);

        const count = try right_hash_map.getOrPut(right);

        if (!count.found_existing) {
            count.value_ptr.* = 1;
        } else {
            count.value_ptr.* += 1;
        }
    }

    while (left_heap.removeOrNull()) |left| {
        const right = right_heap.remove();
        diff_total += @abs(@as(i64, left) - @as(i64, right));
        map_total += left * (right_hash_map.get(left) orelse 0);
    }
    // part 1
    std.debug.print("{d}\n", .{diff_total});
    // part 2
    std.debug.print("{d}\n", .{map_total});
}
