const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const splitScalar = std.mem.splitScalar;

fn pageSort(context: std.AutoHashMap(u16, std.ArrayList(u16)), lhs: u16, rhs: u16) bool {
    const page_rules = context.get(lhs);
    if (page_rules == null) return false;
    for (page_rules.?.items) |page| {
        if (page == rhs) return true;
    }
    return false;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("src/day5/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var result: u64 = 0;
    var bad_result: u64 = 0;

    var order_rules = std.AutoHashMap(u16, std.ArrayList(u16)).init(allocator);
    defer order_rules.deinit();

    var updates = std.ArrayList([]u16).init(allocator);
    defer updates.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.indexOf(u8, line, "|") != null) {
            var it = splitScalar(u8, line, '|');
            const lhs = try parseInt(u16, it.next().?, 10);
            const rhs = try parseInt(u16, it.next().?, 10);

            const rule = try order_rules.getOrPut(lhs);

            if (!rule.found_existing) {
                const restrictions = std.ArrayList(u16).init(allocator);
                // defer restrictions.deinit();, leave it
                rule.value_ptr.* = restrictions;
            }
            try rule.value_ptr.*.append(rhs);
        }
        if (std.mem.indexOf(u8, line, ",") != null) {
            var it = splitScalar(u8, line, ',');
            var update = std.ArrayList(u16).init(allocator);
            defer update.deinit();
            while (it.next()) |num| {
                const page = try parseInt(u16, num, 10);
                try update.append(page);
            }
            const update_copy = try allocator.alloc(u16, update.items.len);
            std.mem.copyForwards(u16, update_copy, update.items);
            try updates.append(update_copy);
        }
    }

    for (updates.items) |update| {
        // check the update
        if (std.sort.isSorted(u16, update, order_rules, pageSort)) {
            result += update[update.len / 2];
        } else {
            std.sort.pdq(u16, update, order_rules, pageSort);
            bad_result += update[update.len / 2];
        }
    }

    // part 1 - 4872
    print("{d}\n", .{result});
    // part 2 - 5564
    print("{d}\n", .{bad_result});
}
