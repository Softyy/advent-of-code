const std = @import("std");
const indexOf = std.mem.indexOf;
const print = std.debug.print;

fn parseInstruction(instruction: []u8) !u64 {
    var it = std.mem.splitScalar(u8, instruction[4 .. instruction.len - 1], ',');

    const maybe_a = it.next().?;
    const a = std.fmt.parseInt(u32, maybe_a, 10) catch return 0;

    if (it.peek() == null) return 0;
    const maybe_b = it.next().?;
    const b = std.fmt.parseInt(u32, maybe_b, 10) catch return 0;

    return a * b;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("src/day3/input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4096]u8 = undefined;

    var total: u64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var offset: usize = 0;
        while (indexOf(u8, line[offset..], "mul(")) |start| {
            if (indexOf(u8, line[offset + start ..], ")")) |end| {
                // possible capture group
                const possible_instruction = line[offset + start .. offset + start + end + 1];
                var refined_instruction: ?[]u8 = null;
                // print("{s}\n", .{possible_instruction});
                if (indexOf(u8, possible_instruction[4..], "mul(")) |nested_start| {
                    if (indexOf(u8, possible_instruction[4 + nested_start ..], ")")) |nested_end| {
                        refined_instruction = possible_instruction[4 + nested_start .. nested_start + nested_end + 4 + 1];
                        // print("refined -> {s}\n", .{refined_instruction.?});
                    }
                }
                var mul: u64 = 0;
                if (refined_instruction != null) {
                    mul = try parseInstruction(refined_instruction.?);
                    refined_instruction = null;
                } else {
                    mul = try parseInstruction(possible_instruction);
                }
                print("{s} = {d}\n", .{ possible_instruction, mul });

                total += mul;
                offset = offset + start + end;
            }
        }
    }
    // 164591437 is too high ?
    print("{d}\n", .{total});
}
