const std = @import("std");
const print = std.debug.print;
const parseInt = std.fmt.parseInt;

const Computer = struct {
    A: u64,
    B: u64,
    C: u64,

    program: []u8,
    instr_ptr: u64,

    out: std.ArrayList(u8),

    fn comboOperand(self: Computer, operand: u8) u64 {
        return switch (operand) {
            0 => 0,
            1 => 1,
            2 => 2,
            3 => 3,
            4 => self.A,
            5 => self.B,
            6 => self.C,
            else => unreachable,
        };
    }

    fn parseOp(self: *Computer, opcode: u8, input: u8) void {
        switch (opcode) {
            0 => {
                const operand = self.comboOperand(input);
                const _A: u64 = self.A / std.math.pow(u64, 2, operand);
                self.A = _A;
            },
            1 => {
                const _B = self.B ^ input;
                self.B = _B;
            },
            2 => {
                const operand = self.comboOperand(input);
                const _B = operand % 8;
                self.B = _B;
            },
            3 => {
                if (!(self.A == 0)) {
                    if (self.instr_ptr != input) {
                        self.instr_ptr = input;
                        return;
                    }
                }
            },
            4 => {
                const _B: u64 = self.B ^ self.C;
                self.B = _B;
            },
            5 => {
                const _out: u8 = @intCast(@mod(self.comboOperand(input), 8));
                self.out.append(_out) catch unreachable;
            },
            6 => {
                const operand = self.comboOperand(input);
                const _B: u64 = self.A / std.math.pow(u64, 2, operand);
                self.B = _B;
            },
            7 => {
                const operand = self.comboOperand(input);
                const _C: u64 = self.A / std.math.pow(u64, 2, operand);
                self.C = _C;
            },
            else => unreachable,
        }
        self.instr_ptr += 2;
    }

    pub fn Exec(self: *Computer) void {
        while (true) {
            if (self.instr_ptr >= self.program.len - 1) return;
            if (self.out.items.len > self.program.len) return;
            const opcode = self.program[self.instr_ptr];
            const operand = self.program[self.instr_ptr + 1];
            self.parseOp(opcode, operand);
        }
    }

    pub fn Output(self: Computer) void {
        var output = std.ArrayList(u8).init(std.heap.page_allocator);
        defer output.deinit();
        for (self.out.items, 0..) |item, i| {
            if (i != 0) {
                output.append(',') catch unreachable;
            }
            output.append(item + '0') catch unreachable;
        }
        print("{s}\n", .{output.items});
    }
};

pub fn main() !void {
    var arena_alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena_alloc.allocator();

    defer arena_alloc.deinit();
    const input_file = @embedFile("input.txt");

    var it = std.mem.splitSequence(u8, input_file, "\n\n");
    const register_str = it.next().?;
    const program_str = it.next().?;
    var register_it = std.mem.splitScalar(u8, register_str, '\n');
    var program_it = std.mem.splitScalar(u8, program_str[9..], ',');

    var program = std.ArrayList(u8).init(allocator);
    defer program.deinit();

    const A: u64 = try parseInt(u64, register_it.next().?[12..], 10);
    const B: u64 = try parseInt(u64, register_it.next().?[12..], 10);
    const C: u64 = try parseInt(u64, register_it.next().?[12..], 10);

    while (program_it.next()) |op| {
        const opcode = try parseInt(u8, op, 10);
        const _op = program_it.next().?;
        const operand: u8 = try parseInt(u8, _op, 10);
        try program.append(opcode);
        try program.append(operand);
    }

    var c = Computer{
        .A = A,
        .B = B,
        .C = C,
        .program = program.items,
        .instr_ptr = 0,
        .out = std.ArrayList(u8).init(allocator),
    };

    c.Exec();
    // part 1 - 1,0,2,0,5,7,2,1,3
    c.Output();
}
