const std = @import("std");
const print = std.debug.print;

const Node = struct {
    name: []const u8,
    cxn: std.ArrayList(Node),

    pub fn contains(self: Node, other: Node) bool {
        for (self.cxn.items) |cxn| {
            if (std.mem.eql(u8, cxn.name, other.name)) return true;
        }
        return false;
    }

    pub fn connect(self: *Node, other: Node) !void {
        if (self.contains(other)) return;
        try self.cxn.append(other);
    }
};

fn networkSet(allocator: std.mem.Allocator, a: []const u8, b: []const u8, c: []const u8) ![]u8 {
    var set = [3][]const u8{ a, b, c };
    std.mem.sort([]const u8, set[0..], {}, struct {
        fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
            return std.mem.order(u8, lhs, rhs) == .lt;
        }
    }.lessThan);
    return std.mem.join(allocator, ",", set[0..]);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const input_file = @embedFile("example.txt");

    var nodes = std.StringHashMap(Node).init(allocator);

    var it = std.mem.splitSequence(u8, input_file, "\n");

    while (it.next()) |line| {
        var node_names = std.mem.splitScalar(u8, line, '-');
        const node_name_1 = node_names.next().?;
        const node_name_2 = node_names.next().?;

        var node_1: Node = undefined;
        if (nodes.get(node_name_1)) |node| {
            node_1 = node;
        } else {
            node_1 = Node{ .name = node_name_1, .cxn = std.ArrayList(Node).init(allocator) };
        }

        var node_2: Node = undefined;
        if (nodes.get(node_name_2)) |node| {
            node_2 = node;
        } else {
            node_2 = Node{ .name = node_name_2, .cxn = std.ArrayList(Node).init(allocator) };
        }
        try node_1.connect(node_2);
        try node_2.connect(node_1);
        try nodes.put(node_1.name, node_1);
        try nodes.put(node_2.name, node_2);
    }

    var node_it = nodes.keyIterator();

    var network_sets = std.StringHashMap(void).init(allocator);
    var p1: u64 = 0;

    while (node_it.next()) |k| {
        const node = nodes.get(k.*).?;
        if (!std.mem.startsWith(u8, node.name, "t")) continue;

        for (0..node.cxn.items.len - 1) |n1| {
            for (n1 + 1..node.cxn.items.len) |n2| {
                var cxn_1 = node.cxn.items[n1];
                cxn_1 = nodes.get(cxn_1.name).?;
                var cxn_2 = node.cxn.items[n2];
                cxn_2 = nodes.get(cxn_2.name).?;

                if (cxn_1.contains(cxn_2)) {
                    const set = try networkSet(allocator, node.name, cxn_1.name, cxn_2.name);
                    if (network_sets.contains(set)) continue;
                    try network_sets.put(set, void{});
                    p1 += 1;
                }
            }
        }
    }

    print("p1={d}\n", .{p1});
    // print("p2={d}\n", .{p2});
}
