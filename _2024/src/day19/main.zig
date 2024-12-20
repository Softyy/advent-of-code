const std = @import("std");
const print = std.debug.print;

fn towelMatch(design: []u8, towels: [][]u8, matchable: *std.StringHashMap(u64)) u64 {
    if (design.len == 0) return 1;
    if (matchable.get(design)) |match| return match;
    var total_count: u64 = 0;
    for (towels) |towel| {
        if (std.mem.startsWith(u8, design, towel)) {
            const count = towelMatch(design[towel.len..], towels, matchable);
            if (count > 0) {
                matchable.put(design[towel.len..], count) catch unreachable;
                total_count += count;
            }
        }
    }
    matchable.put(design, total_count) catch unreachable;
    return total_count;
}

pub fn main() !void {
    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena_alloc.allocator();

    defer arena_alloc.deinit();
    const input_file = @embedFile("input.txt");

    var towels = std.ArrayList([]u8).init(allocator);
    var designs = std.ArrayList([]u8).init(allocator);
    var matchable = std.StringHashMap(u64).init(allocator);

    var it = std.mem.splitSequence(u8, input_file, "\n\n");

    var towels_it = std.mem.splitSequence(u8, it.next().?, ", ");
    var designs_it = std.mem.splitSequence(u8, it.next().?, "\n");

    while (towels_it.next()) |towel| {
        var size = towel.len;
        if (std.mem.indexOf(u8, towel, "\n")) |_| {
            size -= 1;
        }
        const towel_copy = try allocator.alloc(u8, towel.len);
        std.mem.copyForwards(u8, towel_copy, towel);
        try towels.append(towel_copy);
    }

    while (designs_it.next()) |design| {
        const design_copy = try allocator.alloc(u8, design.len);
        std.mem.copyForwards(u8, design_copy, design);
        try designs.append(design_copy);
    }

    var p1: u64 = 0;
    var p2: u64 = 0;

    for (designs.items) |design| {
        const count: u64 = towelMatch(design, towels.items, &matchable);
        if (count > 0) {
            p1 += 1;
            p2 += count;
        }
    }
    // part 1 - 313
    print("Result: {d}\n", .{p1});
    print("Result: {d}\n", .{p2});
}
