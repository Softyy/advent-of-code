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

    pub fn fromCmd(cmd: u8) Dir {
        switch (cmd) {
            '^' => return Dir.N,
            '>' => return Dir.E,
            'v' => return Dir.S,
            '<' => return Dir.W,
            else => unreachable,
        }
    }

    pub fn move(self: Dir, vec: Vec) Vec {
        switch (self) {
            Dir.N => return Vec{ .x = vec.x, .y = vec.y - 1 },
            Dir.E => return Vec{ .x = vec.x + 1, .y = vec.y },
            Dir.S => return Vec{ .x = vec.x, .y = vec.y + 1 },
            Dir.W => return Vec{ .x = vec.x - 1, .y = vec.y },
        }
    }
};

fn canMove(grid: [][]u8, pos: Vec, dir: Dir) bool {
    const next_pos = dir.move(pos);
    const cell = grid[next_pos.y][next_pos.x];
    if (cell == '.') return true;
    if (cell == '#') return false;
    // must be a box
    return canMove(grid, next_pos, dir);
}

fn moveAndPush(obj: u8, obj_pos: Vec, grid: [][]u8, dir: Dir) void {
    const next_pos = dir.move(obj_pos);
    const next_cell = grid[next_pos.y][next_pos.x];
    if (next_cell == 'O') {
        moveAndPush(next_cell, next_pos, grid, dir);
        // could assert the next spot is empty
    }
    grid[obj_pos.y][obj_pos.x] = '.';
    grid[next_pos.y][next_pos.x] = obj;
}

const Robot = struct { pos: Vec };

fn printGrid(grid: [][]u8) void {
    for (grid) |row| {
        for (row) |cell| {
            print("{c}", .{cell});
        }
        print("\n", .{});
    }
}

fn getResult(grid: [][]u8) u64 {
    var result: u64 = 0;
    for (0..grid.len) |y| {
        const row = grid[y];
        for (0..row.len) |x| {
            const cell = row[x];
            if (cell == 'O') {
                result += x + y * 100;
            }
        }
    }
    return result;
}

pub fn main() !void {
    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena_alloc.allocator();

    defer arena_alloc.deinit();
    const input_file = @embedFile("input.txt");

    var it = std.mem.splitSequence(u8, input_file, "\n\n");
    const grid_str = it.next().?;
    const cmd_str = it.next().?;
    var grid_it = std.mem.splitScalar(u8, grid_str, '\n');
    var cmd_it = std.mem.splitScalar(u8, cmd_str, '\n');

    var grid = std.ArrayList([]u8).init(allocator);
    defer grid.deinit();

    var robot: Robot = undefined;

    var y: usize = 0;
    while (grid_it.next()) |line| {
        if (std.mem.indexOf(u8, line, "@")) |x| {
            robot = Robot{ .pos = Vec{ .x = x, .y = y } };
        }
        const line_copy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, line_copy, line);
        try grid.append(line_copy);
        y += 1;
    }

    printGrid(grid.items);

    while (cmd_it.next()) |line| {
        for (line) |cmd| {
            const dir = Dir.fromCmd(cmd);
            if (canMove(grid.items, robot.pos, dir)) {
                moveAndPush('@', robot.pos, grid.items, dir);
                robot.pos = dir.move(robot.pos);
            }
        }
    }

    printGrid(grid.items);

    const result = getResult(grid.items);

    print("Result: {d}\n", .{result});
}
