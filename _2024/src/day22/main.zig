const std = @import("std");
const print = std.debug.print;

fn mix(value: u64, secret_num: u64) u64 {
    return value ^ secret_num;
}

fn prune(secret_num: u64) u64 {
    return secret_num % 16777216;
}

fn evole(num: u64) u64 {
    var next_num: u64 = num;
    next_num = prune(mix(num * 64, num));
    next_num = prune(mix(next_num / 32, next_num));
    next_num = prune(mix(next_num * 2048, next_num));
    return next_num;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const input_file = @embedFile("input.txt");
    var secret_nums = std.ArrayList(u64).init(allocator);

    var it = std.mem.splitSequence(u8, input_file, "\n");

    while (it.next()) |line| {
        const secret_num: u64 = try std.fmt.parseInt(u64, line, 10);
        try secret_nums.append(secret_num);
    }

    var result: u64 = 0;

    for (secret_nums.items) |secret_num| {
        var num = secret_num;
        for (0..2000) |_| {
            num = evole(num);
        }
        result += num;
    }
    print("{d}\n", .{result});
}
