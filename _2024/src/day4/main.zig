const std = @import("std");
const print = std.debug.print;

const Direction = enum { N, NE, E, SE, S, SW, W, NW };
const CoreDirection = enum { N, E, S, W };

fn checkXmas(word: []const u8) bool {
    return std.mem.eql(u8, word, "XMAS");
}

fn checkMas(word: []const u8) bool {
    return std.mem.eql(u8, word, "MAS");
}

fn xmasCheck(g: [][]const u8, dir: Direction, x0: usize, y0: usize) bool {
    const width = g[0].len;
    const height = g.len;

    return switch (dir) {
        Direction.N => y0 >= 3 and checkXmas(&[_]u8{ g[y0][x0], g[y0 - 1][x0], g[y0 - 2][x0], g[y0 - 3][x0] }),
        Direction.NE => y0 >= 3 and x0 + 3 < width and checkXmas(&[_]u8{ g[y0][x0], g[y0 - 1][x0 + 1], g[y0 - 2][x0 + 2], g[y0 - 3][x0 + 3] }),
        Direction.E => x0 + 3 < width and checkXmas(&[_]u8{ g[y0][x0], g[y0][x0 + 1], g[y0][x0 + 2], g[y0][x0 + 3] }),
        Direction.SE => y0 + 3 < height and x0 + 3 < width and checkXmas(&[_]u8{ g[y0][x0], g[y0 + 1][x0 + 1], g[y0 + 2][x0 + 2], g[y0 + 3][x0 + 3] }),
        Direction.S => y0 + 3 < height and checkXmas(&[_]u8{ g[y0][x0], g[y0 + 1][x0], g[y0 + 2][x0], g[y0 + 3][x0] }),
        Direction.SW => y0 + 3 < height and x0 >= 3 and checkXmas(&[_]u8{ g[y0][x0], g[y0 + 1][x0 - 1], g[y0 + 2][x0 - 2], g[y0 + 3][x0 - 3] }),
        Direction.W => x0 >= 3 and checkXmas(&[_]u8{ g[y0][x0], g[y0][x0 - 1], g[y0][x0 - 2], g[y0][x0 - 3] }),
        Direction.NW => y0 >= 3 and x0 >= 3 and checkXmas(&[_]u8{ g[y0][x0], g[y0 - 1][x0 - 1], g[y0 - 2][x0 - 2], g[y0 - 3][x0 - 3] }),
    };
}

fn masCheck(g: [][]const u8, dir: CoreDirection, x0: usize, y0: usize) bool {
    const width = g[0].len;
    const height = g.len;

    if (y0 < 1 or x0 < 1 or y0 + 1 >= height or x0 + 1 >= width) return false;

    return switch (dir) {
        CoreDirection.N => checkMas(&[_]u8{ g[y0 - 1][x0 - 1], g[y0][x0], g[y0 + 1][x0 + 1] }) and checkMas(&[_]u8{ g[y0 - 1][x0 + 1], g[y0][x0], g[y0 + 1][x0 - 1] }),
        CoreDirection.E => checkMas(&[_]u8{ g[y0 - 1][x0 - 1], g[y0][x0], g[y0 + 1][x0 + 1] }) and checkMas(&[_]u8{ g[y0 + 1][x0 - 1], g[y0][x0], g[y0 - 1][x0 + 1] }),
        CoreDirection.S => checkMas(&[_]u8{ g[y0 + 1][x0 - 1], g[y0][x0], g[y0 - 1][x0 + 1] }) and checkMas(&[_]u8{ g[y0 + 1][x0 + 1], g[y0][x0], g[y0 - 1][x0 - 1] }),
        CoreDirection.W => checkMas(&[_]u8{ g[y0 - 1][x0 + 1], g[y0][x0], g[y0 + 1][x0 - 1] }) and checkMas(&[_]u8{ g[y0 + 1][x0 + 1], g[y0][x0], g[y0 - 1][x0 - 1] }),
    };
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("src/day4/example.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var xmas_count: u64 = 0;
    var x_mas_count: u64 = 0;

    var word_grid = std.ArrayList([]u8).init(allocator);
    defer word_grid.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_copy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, line_copy, line);
        try word_grid.append(line_copy);
    }

    for (0..word_grid.items.len) |y| {
        const row = word_grid.items[y];
        for (0..row.len) |x| {
            inline for (std.meta.fields(Direction)) |dir| {
                const direction: Direction = @enumFromInt(dir.value);
                if (xmasCheck(
                    word_grid.items,
                    direction,
                    x,
                    y,
                )) {
                    xmas_count += 1;
                }
            }

            inline for (std.meta.fields(CoreDirection)) |dir| {
                const direction: CoreDirection = @enumFromInt(dir.value);
                if (masCheck(
                    word_grid.items,
                    direction,
                    x,
                    y,
                )) {
                    x_mas_count += 1;
                }
            }
        }
    }
    // part 1 - 2578
    print("{d}\n", .{xmas_count});
    // part 2 - 1972
    print("{d}\n", .{x_mas_count});
}
