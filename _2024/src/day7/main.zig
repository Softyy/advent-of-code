const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;
const splitScalar = std.mem.splitScalar;

const Equation = struct {
    total: u64,
    values: []u16,

    pub fn possiblyTrue(self: Equation) bool {
        const first_value = self.values[0];
        return self.branchCheck(self.values[1..], first_value);
    }

    fn branchCheck(self: Equation, values_remaining: []u16, running_total: u64) bool {
        if (self.total < running_total) return false;
        if (values_remaining.len == 0) return self.total == running_total;
        const value = values_remaining[0];

        // part 2
        var buffer: [40]u8 = undefined; // Buffer large enough to hold the concatenated string
        const concated_value_str = std.fmt.bufPrint(&buffer, "{d}{d}", .{ running_total, value }) catch unreachable;
        const concated_value = std.fmt.parseInt(u64, concated_value_str, 10) catch unreachable;

        return (self.branchCheck(values_remaining[1..], running_total + value) or
            self.branchCheck(values_remaining[1..], running_total * value) or
            self.branchCheck(values_remaining[1..], concated_value));
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("src/day7/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var result: u64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitSequence(u8, line, ": ");
        const total = try parseInt(u64, it.next().?, 10);
        var raw_values = splitScalar(u8, it.next().?, ' ');

        var values = std.ArrayList(u16).init(allocator);
        defer values.deinit();

        while (raw_values.next()) |raw_value| {
            try values.append(try parseInt(u16, raw_value, 10));
        }

        const equation = Equation{ .total = total, .values = values.items };

        if (equation.possiblyTrue()) {
            result += equation.total;
        }
    }

    // part 1 - 663613490587
    // part 2 - 110365987435001

    print("{d}\n", .{result});
}
