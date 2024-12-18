const std = @import("std");
const print = std.debug.print;

const Vec = struct {
    x: usize,
    y: usize,
};

const Dir = enum {
    N,
    E,
    S,
    W,

    pub fn move(self: Dir, vec: Vec) Vec {
        switch (self) {
            Dir.N => return Vec{ .x = vec.x, .y = vec.y - 1 },
            Dir.E => return Vec{ .x = vec.x + 1, .y = vec.y },
            Dir.S => return Vec{ .x = vec.x, .y = vec.y + 1 },
            Dir.W => return Vec{ .x = vec.x - 1, .y = vec.y },
        }
    }
};

const Corrupted: u16 = std.math.maxInt(u16);

fn printGrid(grid: [][]u16) void {
    for (grid) |row| {
        for (row) |cell| {
            print("{} ", .{cell});
        }
        print("\n", .{});
    }
    print("\n", .{});
}

fn updateCell(grid: [][]u16, pos: Vec) bool {
    if (grid[pos.y][pos.x] == Corrupted) return false;
    const L = if (pos.x > 0)
        grid[Dir.W.move(pos).y][Dir.W.move(pos).x]
    else
        Corrupted;
    const R = if (pos.x < grid[0].len - 1)
        grid[Dir.E.move(pos).y][Dir.E.move(pos).x]
    else
        Corrupted;
    const U = if (pos.y > 0)
        grid[Dir.N.move(pos).y][Dir.N.move(pos).x]
    else
        Corrupted;
    const D = if (pos.y < grid.len - 1)
        grid[Dir.S.move(pos).y][Dir.S.move(pos).x]
    else
        Corrupted;
    var new_cell: u16 = @min(@min(@min(L, U), R), D);
    if (new_cell != Corrupted) new_cell += 1;
    const updated = grid[pos.y][pos.x] != new_cell;
    grid[pos.y][pos.x] = new_cell;
    return updated;
}

fn updateCross(grid: [][]u16, pos: Vec) void {
    if (pos.x > 0) {
        const new_pos = Dir.W.move(pos);
        if (updateCell(grid, new_pos)) {
            updateCross(grid, new_pos);
        }
    }
    if (pos.x < grid[0].len - 1) {
        const new_pos = Dir.E.move(pos);
        if (updateCell(grid, new_pos)) {
            updateCross(grid, new_pos);
        }
    }
    if (pos.y > 0) {
        const new_pos = Dir.N.move(pos);
        if (updateCell(grid, new_pos)) {
            updateCross(grid, new_pos);
        }
    }
    if (pos.y < grid.len - 1) {
        const new_pos = Dir.S.move(pos);
        if (updateCell(grid, new_pos)) {
            updateCross(grid, new_pos);
        }
    }
}

fn updateGrid(grid: [][]u16, pos: Vec) void {
    grid[pos.y][pos.x] = Corrupted;
    updateCross(grid, pos);
}

pub fn main() !void {
    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena_alloc.allocator();

    defer arena_alloc.deinit();
    const file_name = "input.txt";
    const input_file = @embedFile(file_name);
    const max_x: u32 = if (std.mem.eql(u8, file_name, "input.txt")) 70 else 6;
    const max_y: u32 = if (std.mem.eql(u8, file_name, "input.txt")) 70 else 6;

    var bytes = std.ArrayList(Vec).init(allocator);

    var it = std.mem.splitSequence(u8, input_file, "\n");

    const exit = Vec{ .x = max_x, .y = max_y };

    var grid = try allocator.alloc([]u16, max_y + 1);

    while (it.next()) |line| {
        var _it = std.mem.splitScalar(u8, line, ',');
        const x = try std.fmt.parseInt(u16, _it.next().?, 10);
        const y = try std.fmt.parseInt(u16, _it.next().?, 10);
        try bytes.append(Vec{ .x = x, .y = y });
    }

    for (0..max_y + 1) |y| {
        var row = try allocator.alloc(u16, max_x + 1);
        for (0..max_x + 1) |x| {
            row[x] = @intCast(x + y);
        }
        grid[y] = row;
    }

    // let it rain
    // example - 12
    // input - 1024
    for (bytes.items) |byte| {
        updateGrid(grid, byte);
        // printGrid(grid);
        if (grid[exit.y][exit.x] == Corrupted) {
            print("Result: {}\n", .{byte});
            break;
        }
    }

    // part 1 - 310
    // part 2 - 16,46

    print("Result: {d}\n", .{grid[exit.y][exit.x]});
}
