const std = @import("std");
const Order = std.math.Order;
const assert = std.debug.assert;

fn isValid(nums: []i32) !bool {
    var last_num: ?i32 = null;
    var diffs = std.ArrayList(i32).init(std.heap.page_allocator);
    defer diffs.deinit();

    for (nums) |num| {
        if (last_num != null) {
            const diff = @as(i32, num) - @as(i32, last_num.?);
            try diffs.append(diff);
        }
        last_num = num;
    }

    // check for all the same signs
    for (0..diffs.items.len - 1) |i| {
        if ((diffs.items[i] ^ diffs.items[i + 1]) < 0) {
            return false;
        }
    }
    // check for bounds
    for (diffs.items) |diff| {
        if (@abs(diff) > 3 or diff == 0) {
            return false;
        }
    }

    return true;
}
pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("src/day2/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var safe_reports: u64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitScalar(u8, line, ' ');
        var nums = std.ArrayList(i32).init(std.heap.page_allocator);
        defer nums.deinit();

        while (it.next()) |s| {
            const num = try std.fmt.parseInt(u16, s, 10);
            try nums.append(num);
        }

        for (0..nums.items.len) |i| {
            var subnums = std.ArrayList(i32).init(std.heap.page_allocator);
            defer subnums.deinit();

            for (nums.items[0..i]) |num| {
                try subnums.append(num);
            }
            for (nums.items[i + 1 ..]) |num| {
                try subnums.append(num);
            }

            if (try isValid(subnums.items)) {
                safe_reports += 1;
                break;
            }
        }
    }

    // part 1 279, // part 2 343
    std.debug.print("{d}\n", .{safe_reports});
}
