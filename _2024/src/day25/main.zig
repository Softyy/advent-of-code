const std = @import("std");
const print = std.debug.print;

fn fits(lock: [5]u4, key: [5]u4) bool {
    for (0..5) |n| {
        if (lock[n] + key[n] > 5) return false;
    }
    return true;
}
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const input_file = @embedFile("input.txt");

    var it = std.mem.splitSequence(u8, input_file, "\n\n");

    var locks = std.ArrayList([5]u4).init(allocator);
    var keys = std.ArrayList([5]u4).init(allocator);

    while (it.next()) |line| {
        var _it = std.mem.splitSequence(u8, line, "\n");

        var item: [5]u4 = .{ 0, 0, 0, 0, 0 };
        const is_lock = std.mem.eql(u8, _it.next().?, "#####");

        for (0..5) |_| {
            const row = _it.next().?;
            for (0..5) |m| {
                if (row[m] == '#') item[m] += 1;
            }
        }
        if (is_lock) {
            try locks.append(item);
        } else {
            try keys.append(item);
        }
    }

    var r: u32 = 0;
    for (locks.items) |lock| {
        for (keys.items) |key| {
            if (fits(lock, key)) r += 1;
        }
    }

    print("p1={d}\n", .{r});
}
