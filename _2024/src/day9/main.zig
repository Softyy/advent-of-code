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
    const file = @embedFile("input.txt");

    // setup blocks
    var blocks = std.ArrayList(u16).init(allocator);
    defer blocks.deinit();

    var free_blocks = std.ArrayList(FreeBlock).init(allocator);
    defer free_blocks.deinit();
    var file_blocks = std.ArrayList(FileBlock).init(allocator);
    defer file_blocks.deinit();

    const free_space: u16 = 0; // Note: 0 ~ . in the README
    _ = free_space; // autofix
    var file_id: u16 = 0;
    var flip_flop: bool = true;
    var offset: usize = 0;
    for (file, 0..) |char, idx| {
        _ = idx; // autofix
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
            if (file_blocks.items[i].start < free_blocks.items[j].end) break;
            if (free_blocks.items[j].len() >= file_blocks.items[i].len()) {
                file_blocks.items[i].end = free_blocks.items[j].start + file_blocks.items[i].len();
                file_blocks.items[i].start = free_blocks.items[j].start;
                if (file_blocks.items[i].len() == free_blocks.items[j].len()) {
                    _ = free_blocks.orderedRemove(j);
                } else {
                    free_blocks.items[j].start = free_blocks.items[j].start + file_blocks.items[i].len();
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
