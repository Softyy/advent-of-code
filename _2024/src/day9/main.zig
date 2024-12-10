const std = @import("std");
const print = std.debug.print;

const FreeBlock = struct {
    start: usize,
    end: usize,

    pub fn len(self: FreeBlock) usize {
        return self.end - self.start;
    }
};

const FileBlock = struct {
    id: u16,
    start: usize,
    end: usize,

    pub fn len(self: FileBlock) usize {
        return self.end - self.start;
    }

    pub fn checkSum(self: FileBlock) u64 {
        var sum: u64 = 0;
        for (self.start..self.end) |idx| {
            sum += idx * self.id;
        }
        return sum;
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input_file = @embedFile("input.txt");

    // setup blocks

    var free_blocks = std.ArrayList(FreeBlock).init(allocator);
    defer free_blocks.deinit();
    var file_blocks = std.ArrayList(FileBlock).init(allocator);
    defer file_blocks.deinit();

    var file_id: u16 = 0;
    var flip_flop: bool = true;
    var offset: usize = 0;

    for (input_file) |char| {
        const int_value: u8 = @as(u8, char) - @as(u8, '0');
        if (flip_flop) {
            const block = FileBlock{
                .id = file_id,
                .start = offset,
                .end = offset + int_value,
            };
            try file_blocks.append(block);
            file_id += 1;
        } else {
            const block = FreeBlock{
                .start = offset,
                .end = offset + int_value,
            };
            try free_blocks.append(block);
        }
        flip_flop = !flip_flop;
        offset += int_value;
    }

    // defrag
    var i: usize = file_blocks.items.len;
    while (i > 0) {
        i -= 1;
        for (0..free_blocks.items.len) |j| {
            var file = &file_blocks.items[i];
            var free = &free_blocks.items[j];
            if (file.start < free.end) break;
            if (free.len() >= file.len()) {
                file.end = free.start + file.len();
                file.start = free.start;
                if (file.len() == free.len()) {
                    _ = free_blocks.orderedRemove(j);
                } else {
                    free.start = free.start + file.len();
                }
                break;
            }
        }
    }

    var result: u64 = 0;
    for (file_blocks.items) |file_block| {
        result += file_block.checkSum();
    }

    // part 1 - 6349606724455
    // part 2 - 6376648986651
    print("{d}\n", .{result});
}
