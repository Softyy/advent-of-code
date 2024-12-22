const std = @import("std");
const print = std.debug.print;

const NumMap = std.StaticStringMap([]const u8).initComptime(.{
    .{ "00", "" },
    .{ "01", "^<" },
    .{ "02", "^" },
    .{ "03", "^>" },
    .{ "04", "^^<" },
    .{ "05", "^^" },
    .{ "06", "^^>" },
    .{ "07", "^^^<" },
    .{ "08", "^^^" },
    .{ "09", "^^^>" },
    .{ "0A", ">" },
    .{ "00", "" },
    .{ "10", ">v" },
    .{ "11", ">v" },
    .{ "12", ">" },
    .{ "13", ">>" },
    .{ "14", ">" },
    .{ "15", ">^" },
    .{ "16", ">>^" },
    .{ "17", "^^" },
    .{ "18", ">^^" },
    .{ "19", ">>^^" },
    .{ "1A", ">>v" },
    .{ "20", "v" },
    .{ "21", "<" },
    .{ "22", "" },
    .{ "23", ">" },
    .{ "24", "^<" },
    .{ "25", "^^" },
    .{ "26", "^>" },
    .{ "27", "^^<" },
    .{ "28", "^^" },
    .{ "29", "^^>" },
    .{ "2A", "v>" },
    .{ "30", "<v" },
    .{ "31", "<<" },
    .{ "32", "<" },
    .{ "33", "" },
    .{ "34", "<<^" },
    .{ "35", "<^" },
    .{ "36", "^" },
    .{ "37", "<<^^" },
    .{ "38", "<^^" },
    .{ "39", "^^" },
    .{ "3A", "v" },
    .{ "40", ">vv" },
    .{ "41", "v" },
    .{ "42", ">v" },
    .{ "43", ">>v" },
    .{ "44", "" },
    .{ "45", ">" },
    .{ "46", ">>" },
    .{ "47", "^" },
    .{ "48", ">^" },
    .{ "49", ">>^" },
    .{ "4A", ">>vv" },
    .{ "50", "vv" },
    .{ "51", "v<" },
    .{ "52", "v" },
    .{ "53", "v>" },
    .{ "54", "<" },
    .{ "55", "" },
    .{ "56", ">" },
    .{ "57", "<^" },
    .{ "58", "^" },
    .{ "59", "^>" },
    .{ "5A", "vv>" },
    .{ "60", "<vv" },
    .{ "61", "<<v" },
    .{ "62", "<v" },
    .{ "63", "v" },
    .{ "64", "<<" },
    .{ "65", "<" },
    .{ "66", "" },
    .{ "67", "<<^" },
    .{ "68", "<^" },
    .{ "69", "^" },
    .{ "6A", "vv" },
    .{ "70", ">vvv" },
    .{ "71", "vv" },
    .{ "72", ">vv" },
    .{ "73", ">>vv" },
    .{ "74", "v" },
    .{ "75", ">v" },
    .{ "76", ">>v" },
    .{ "77", "" },
    .{ "78", ">" },
    .{ "79", ">>" },
    .{ "7A", ">>vvv" },
    .{ "80", "vvv" },
    .{ "81", "<vv" },
    .{ "82", "vv" },
    .{ "83", ">vv" },
    .{ "84", "<v" },
    .{ "85", "v" },
    .{ "86", ">v" },
    .{ "87", "<" },
    .{ "88", "" },
    .{ "89", ">" },
    .{ "8A", ">vvv" },
    .{ "90", "<vvv" },
    .{ "91", "<<vv" },
    .{ "92", "<vv" },
    .{ "93", "vv" },
    .{ "94", "<<v" },
    .{ "95", "<v" },
    .{ "96", "v" },
    .{ "97", "<<" },
    .{ "98", "<" },
    .{ "99", "" },
    .{ "9A", "vvv" },
    .{ "A0", "<" },
    .{ "A1", "^<<" },
    .{ "A2", "^<" },
    .{ "A3", "^" },
    .{ "A4", "^^<<" },
    .{ "A5", "^^<" },
    .{ "A6", "^^" },
    .{ "A7", "^^^<<" },
    .{ "A8", "^^^<" },
    .{ "A9", "^^^" },
    .{ "AA", "" },
});

// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//     | 0 | A |
//     +---+---+

const DirMap = std.StaticStringMap([]const u8).initComptime(.{
    .{ "AA", "" },
    .{ "A^", "<" },
    .{ "A>", "v" },
    .{ "Av", "v<" },
    .{ "A<", "v<<" },
    .{ "^A", ">" },
    .{ "^^", "" },
    .{ "^>", "v>" },
    .{ "^v", "v" },
    .{ "^<", "v<" },
    .{ ">A", "^" },
    .{ ">^", "^<" },
    .{ ">>", "" },
    .{ ">v", "<" },
    .{ "><", "<<" },
    .{ "vA", "^>" },
    .{ "v^", "^" },
    .{ "v>", ">" },
    .{ "vv", "" },
    .{ "v<", "<" },
    .{ "<A", ">>^" },
    .{ "<^", ">^" },
    .{ "<>", ">>" },
    .{ "<v", ">" },
    .{ "<<", "" },
});

//     +---+---+
//     | ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+

fn push(
    code: []u8,
    map: std.StaticStringMap([]const u8),
    allocator: std.mem.Allocator,
) []u8 {
    var dirs = std.ArrayList(u8).init(allocator);
    dirs.append('A') catch unreachable;
    for (0..code.len - 1) |n| {
        const mov = code[n .. n + 2];
        const combo = map.get(mov).?;
        const combo_clone = allocator.alloc(u8, combo.len) catch unreachable;
        std.mem.copyForwards(u8, combo_clone, combo);

        const cmd = allocator.alloc(u8, combo.len + 1) catch unreachable;
        const cmd_alt = allocator.alloc(u8, combo.len + 1) catch unreachable;
        std.mem.copyForwards(u8, cmd[0..combo.len], combo);
        cmd[combo.len] = 'A'; //push the button;;

        if (dirs.getLast() == cmd[0]) {
            dirs.appendSlice(cmd) catch unreachable;
            continue;
        }

        std.mem.reverse(u8, combo_clone);
        std.mem.copyForwards(u8, cmd_alt[0..combo.len], combo_clone);

        cmd_alt[combo.len] = 'A'; //push the button
        dirs.appendSlice(cmd_alt) catch unreachable;
    }
    return dirs.items;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const input_file = @embedFile("example.txt");

    var codes = std.ArrayList([]u8).init(allocator);

    var it = std.mem.splitSequence(u8, input_file, "\n");

    while (it.next()) |line| {
        const line_copy = try allocator.alloc(u8, line.len + 1);
        line_copy[0] = 'A'; //robot starts at A
        std.mem.copyForwards(u8, line_copy[1..], line);
        try codes.append(line_copy);
    }

    var result: u64 = 0;

    for (codes.items) |code| {
        const r1 = push(code, NumMap, allocator);
        const r2 = push(r1, DirMap, allocator);
        const r3 = push(r2, DirMap, allocator);

        const num = try std.fmt.parseInt(u16, code[1 .. code.len - 1], 10);
        result += num * (r3.len - 1);
        print("{s}\n{s}\n{s}\n{s}\n", .{ r3, r2, r1, code });
    }
    // 126384
    // too high 198336

    print("{d}\n", .{result});
}
