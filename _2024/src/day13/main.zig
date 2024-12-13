const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const Vec = struct {
    x: i64,
    y: i64,
};

const Matrix = struct {
    a11: i64,
    a12: i64,
    a21: i64,
    a22: i64,

    pub fn InverseMul(self: Matrix, vec: Vec) ?Vec {
        const det = self.Determinate();
        if (det == 0) {
            print("panic!", .{});
            return null;
        }
        const x = self.a22 * vec.x - self.a21 * vec.y;

        const y = self.a11 * vec.y - self.a12 * vec.x;
        if (@mod(x, det) != 0 or @mod(y, det) != 0) {
            return null;
        }
        return Vec{ .x = @divExact(x, det), .y = @divExact(y, det) };
    }

    pub fn Determinate(self: Matrix) i64 {
        return self.a11 * self.a22 - self.a12 * self.a21;
    }
};

const Problem = struct {
    matrix: Matrix,
    prize: Vec,

    pub fn Solve(self: Problem) ?Vec {
        return self.matrix.InverseMul(self.prize);
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input_file = @embedFile("input.txt");
    var eq_it = std.mem.splitSequence(u8, input_file, "\n\n");

    var problems = std.ArrayList(Problem).init(allocator);

    while (eq_it.next()) |eq| {
        var line = std.mem.splitScalar(u8, eq, '\n');
        const button_a_line = line.next().?;
        const button_b_line = line.next().?;
        const prize_line = line.next().?;

        var _a = std.mem.splitScalar(u8, button_a_line[12..], ',');
        const a11 = try parseInt(u32, _a.next().?, 10);
        const a12 = try parseInt(u32, _a.next().?[3..], 10);

        var _b = std.mem.splitScalar(u8, button_b_line[12..], ',');

        const a21 = try parseInt(u32, _b.next().?, 10);
        const a22 = try parseInt(u32, _b.next().?[3..], 10);

        var _p = std.mem.splitScalar(u8, prize_line[9..], ',');
        const x = try parseInt(u32, _p.next().?, 10);
        const y = try parseInt(u32, _p.next().?[3..], 10);

        // part 2

        const unit_conversion: i64 = 10000000000000;

        try problems.append(Problem{
            .matrix = Matrix{
                .a11 = a11,
                .a12 = a12,
                .a21 = a21,
                .a22 = a22,
            },
            .prize = Vec{
                .x = x + unit_conversion,
                .y = y + unit_conversion,
            },
        });
    }

    var result: i64 = 0;
    for (problems.items) |problem| {
        const maybe_soln = problem.Solve();
        if (maybe_soln) |soln| {
            result += soln.x * 3 + soln.y * 1;
        }
    }

    // part 1 - 183248
    print("{d}\n", .{result});
}
