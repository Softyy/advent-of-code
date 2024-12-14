const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const Vec = struct {
    x: i64,
    y: i64,
};

const Robot = struct {
    p: Vec,
    v: Vec,

    pub fn move(self: Robot, seconds: u32, max_x: u32, max_y: u32) Vec {
        const x = @mod(self.p.x + (self.v.x * seconds), max_x);
        const y = @mod(self.p.y + (self.v.y * seconds), max_y);

        return Vec{ .x = x, .y = y };
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_name = "input.txt";
    const input_file = @embedFile(file_name);
    const max_x: u32 = if (std.mem.eql(u8, file_name, "input.txt")) 101 else 11;
    const max_y: u32 = if (std.mem.eql(u8, file_name, "input.txt")) 103 else 7;

    var robots = std.ArrayList(Robot).init(allocator);

    var it = std.mem.splitScalar(u8, input_file, '\n');

    while (it.next()) |line| {
        var _it = std.mem.splitScalar(u8, line, ' ');
        const pos = _it.next().?;
        const vec = _it.next().?;

        var _p = std.mem.splitScalar(u8, pos[2..], ',');
        const _px = try parseInt(i64, _p.next().?, 10);
        const _py = try parseInt(i64, _p.next().?, 10);

        var _v = std.mem.splitScalar(u8, vec[2..], ',');
        const _vx = try parseInt(i64, _v.next().?, 10);
        const _vy = try parseInt(i64, _v.next().?, 10);

        try robots.append(Robot{
            .p = Vec{ .x = _px, .y = _py },
            .v = Vec{ .x = _vx, .y = _vy },
        });
    }

    var top_left: u64 = 0;
    var top_right: u64 = 0;
    var bot_left: u64 = 0;
    var bot_right: u64 = 0;

    const mid_x: u32 = (max_x - 1) / 2;
    const mid_y: u32 = (max_y - 1) / 2;

    for (robots.items) |robot| {
        const pos = robot.move(100, max_x, max_y);
        if (pos.x < mid_x and pos.y < mid_y) {
            top_left += 1;
        }
        if (pos.x > mid_x and pos.y < mid_y) {
            top_right += 1;
        }
        if (pos.x < mid_x and pos.y > mid_y) {
            bot_left += 1;
        }
        if (pos.x > mid_x and pos.y > mid_y) {
            bot_right += 1;
        }
    }
    const result = top_left * top_right * bot_left * bot_right;

    // part 1 -
    print("{d}\n", .{result});
}
