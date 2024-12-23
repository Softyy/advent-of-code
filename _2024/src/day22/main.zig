const std = @import("std");
const print = std.debug.print;

fn mix(value: u64, secret_num: u64) u64 {
    return value ^ secret_num;
}

fn prune(secret_num: u64) u64 {
    return secret_num % 16777216;
}

fn firstDigit(num: u64) u8 {
    var x = num;
    x = x % 10;
    return @as(u8, @intCast(x));
}

fn evole(num: u64) u64 {
    var next_num: u64 = num;
    next_num = prune(mix(next_num * 64, next_num));
    next_num = prune(mix(next_num / 32, next_num));
    next_num = prune(mix(next_num * 2048, next_num));
    return next_num;
}

const Changes = struct {
    _1: i16,
    _2: i16,
    _3: i16,
    _4: i16,

    pub fn push(self: *Changes, change: i16) Changes {
        return Changes{
            ._1 = self._2,
            ._2 = self._3,
            ._3 = self._4,
            ._4 = change,
        };
    }
};

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

    var p1: u64 = 0;
    var p2: u64 = 0;

    var changes_to_choose_from = std.AutoHashMap(Changes, u32).init(allocator);

    for (secret_nums.items) |secret_num| {
        var change_sequence = std.AutoHashMap(Changes, u32).init(allocator);
        defer change_sequence.deinit();
        var num = secret_num;
        var last_num_of_bananas: u8 = 0;
        var num_of_bananas: u8 = 0;
        last_num_of_bananas = firstDigit(num);

        var starting_changes: [4]i16 = undefined;

        for (0..4) |n| {
            num = evole(num);
            num_of_bananas = firstDigit(num);
            starting_changes[n] = @as(i16, @intCast(num_of_bananas)) - last_num_of_bananas;
            last_num_of_bananas = num_of_bananas;
        }

        var change = Changes{
            ._1 = starting_changes[0],
            ._2 = starting_changes[1],
            ._3 = starting_changes[2],
            ._4 = starting_changes[3],
        };

        try change_sequence.put(change, num_of_bananas);

        for (4..2000) |_| {
            num = evole(num);
            num_of_bananas = firstDigit(num);
            change = change.push(@as(i16, @intCast(num_of_bananas)) - last_num_of_bananas);
            const key = try change_sequence.getOrPut(change);
            if (key.found_existing) {
                if (key.value_ptr.* < num_of_bananas) key.value_ptr.* = num_of_bananas;
            } else {
                key.value_ptr.* = num_of_bananas;
            }
            last_num_of_bananas = num_of_bananas;
        }
        p1 += num;
        var key_it = change_sequence.keyIterator();
        while (key_it.next()) |k| {
            const val = change_sequence.get(k.*).?;
            const key = try changes_to_choose_from.getOrPut(k.*);

            if (key.found_existing) {
                key.value_ptr.* += val;
            } else {
                key.value_ptr.* = val;
            }
        }
    }

    var changes_to_choose_from_it = changes_to_choose_from.valueIterator();
    while (changes_to_choose_from_it.next()) |total_bananas| {
        if (total_bananas.* > p2) {
            p2 = total_bananas.*;
        }
    }

    //  check for best sequence
    print("p1={d}\n", .{p1});
    print("p2={d}\n", .{p2});

    // 2440 is too high, 2259 is to low :S
}
