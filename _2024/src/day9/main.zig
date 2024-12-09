const std = @import("std");
const print = std.debug.print;

fn checkSum(blocks: []u16) u64 {
    var sum: u64 = 0;
    for (0..blocks.len) |idx| {
        const block = blocks[idx];
        if (block != 0) {
            sum += idx * (blocks[idx] - 1);
        }
    }
    return sum;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file = @embedFile("input.txt");

    // setup blocks
    var blocks = std.ArrayList(u16).init(allocator);
    const free_space: u16 = 0; // Note: 0 ~ . in the README
    var file_id: u16 = 1;
    var flip_flop: bool = true;
    for (file) |char| {
        const int_value: u8 = @as(u8, char) - @as(u8, '0');
        if (flip_flop) {
            for (0..int_value) |_| {
                try blocks.append(file_id);
            }
            file_id += 1;
        } else {
            for (0..int_value) |_| {
                try blocks.append(free_space);
            }
        }
        flip_flop = !flip_flop;
    }

    // defrag
    var l: usize = 0;
    var r: usize = blocks.items.len - 1;

    while (l != r) {
        const left = blocks.items[l];
        if (left != 0) {
            // not free
            l += 1;
            continue;
        }
        const right = blocks.items[r];
        if (right == 0) {
            // free
            r -= 1;
            continue;
        }
        // left is free, and right is not... swap
        blocks.items[l] = blocks.items[r];
        blocks.items[r] = free_space;
        l += 1;
    }

    print("{d}\n", .{checkSum(blocks.items)});
}
