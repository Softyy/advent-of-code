const std = @import("std");
const print = std.debug.print;

fn calculate(states: *std.StringHashMap(u1), ops: std.StringHashMap([]const u8), out: []const u8) !u1 {
    const cmd = ops.get(out).?;
    var cmd_it = std.mem.splitSequence(u8, cmd, " ");
    const arg1_name = cmd_it.next().?;
    const op = cmd_it.next().?;
    const arg2_name = cmd_it.next().?;

    var arg1 = states.get(arg1_name);
    if (arg1 == null) arg1 = try calculate(states, ops, arg1_name);

    var arg2 = states.get(arg2_name);
    if (arg2 == null) arg2 = try calculate(states, ops, arg2_name);

    var value: u1 = undefined;
    if (std.mem.eql(u8, op, "AND")) value = arg1.? & arg2.?;
    if (std.mem.eql(u8, op, "OR")) value = arg1.? | arg2.?;
    if (std.mem.eql(u8, op, "XOR")) value = arg1.? ^ arg2.?;

    try states.put(out, value);
    return value;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const input_file = @embedFile("input.txt");

    var it = std.mem.splitSequence(u8, input_file, "\n\n");
    var init_state_it = std.mem.splitSequence(u8, it.next().?, "\n");
    var op_it = std.mem.splitSequence(u8, it.next().?, "\n");

    var states = std.StringHashMap(u1).init(allocator);
    var ops = std.StringHashMap([]const u8).init(allocator);

    while (init_state_it.next()) |line| {
        var _it = std.mem.splitSequence(u8, line, ": ");
        const state_name = _it.next().?;
        const state_value: u1 = @intCast(_it.next().?[0] - '0');
        try states.put(state_name, state_value);
    }

    while (op_it.next()) |line| {
        var _it = std.mem.splitSequence(u8, line, " -> ");
        const cmd = _it.next().?;
        const out = _it.next().?;
        try ops.put(out, cmd);
    }

    var ops_it = ops.keyIterator();

    while (ops_it.next()) |out| {
        if (states.contains(out.*)) continue; // already calculated
        _ = try calculate(&states, ops, out.*);
    }

    var z: u64 = 0;
    var state_it = states.keyIterator();
    while (state_it.next()) |k| {
        if (std.mem.startsWith(u8, k.*, "z")) {
            if (states.get(k.*) == 0) continue;
            const pos: u8 = try std.fmt.parseInt(u8, k.*[1..3], 10);
            z += std.math.pow(u64, 2, pos);
        }
    }

    print("{d}\n", .{z});
}
