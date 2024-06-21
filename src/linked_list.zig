const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Create a LinkedList for type T
pub fn LinkedList(comptime T: type) type {
    return struct {
        head: ?*Node,
        tail: ?*Node,

        const Self = @This();

        pub const Node = struct {
            value: T,
            next: ?*Node = null,
            previous: ?*Node = null,

            pub const Data = T;
        };

        /// Initialize the LinkedList
        pub fn init() Self {
            return Self{
                .head = null,
                .tail = null,
            };
        }

        pub fn deinit(self: *Self) void {
            var current = self.head;
            while (current) |cur| {
                current = cur.next;
                cur.previous = null;
                cur.next = null;
            }
            self.head = null;
            self.tail = null;
        }

        pub fn addFirst(self: *Self, node: *Node) void {
            node.next = self.head;
            if (self.head) |head| {
                head.previous = node;
            }
            self.head = node;

            if (self.tail == null) {
                self.tail = node;
            }
        }

        pub fn addLast(self: *Self, node: *Node) void {
            node.previous = self.tail;
            if (self.tail) |tail| {
                tail.next = node;
            }
            self.tail = node;

            if (self.head == null) {
                self.head = node;
            }
        }

        pub fn detach(self: *Self, node: *Node) void {
            if (node.previous) |prev| {
                prev.next = node.next;
            }
            if (node.next) |next| {
                next.previous = node.previous;
            }

            if (node == self.head) {
                self.head = node.next;
            }
            if (node == self.tail) {
                self.tail = node.previous;
            }
        }

        fn headToTailArray(self: *Self, allocator: Allocator) ![]T {
            var arrayList = ArrayList(T).init(allocator);
            errdefer arrayList.deinit();
            var current = self.head;
            while (current) |cur| {
                try arrayList.append(cur.value);
                current = cur.next;
            }
            return try arrayList.toOwnedSlice();
        }

        fn tailToHeadArray(self: *Self, allocator: Allocator) ![]T {
            var arrayList = ArrayList(T).init(allocator);
            errdefer arrayList.deinit();
            var current = self.tail;
            while (current) |cur| {
                try arrayList.append(cur.value);
                current = cur.previous;
            }
            return try arrayList.toOwnedSlice();
        }
    };
}

const testing = std.testing;

test "LinkedList addLast" {
    var allocator = std.testing.allocator;
    const List = LinkedList(i32);
    const Node = List.Node;
    var linkedList = List.init();
    defer linkedList.deinit();

    var node1 = Node{ .value = 1 };
    var node2 = Node{ .value = 2 };
    var node3 = Node{ .value = 3 };
    var node4 = Node{ .value = 4 };
    var node5 = Node{ .value = 5 };

    linkedList.addLast(&node1);
    linkedList.addLast(&node2);
    linkedList.addLast(&node3);
    linkedList.addLast(&node4);
    linkedList.addLast(&node5);

    const headToTail = try linkedList.headToTailArray(allocator);
    defer allocator.free(headToTail);
    try testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5 }, headToTail);

    const tailToHead = try linkedList.tailToHeadArray(allocator);
    defer allocator.free(tailToHead);
    try testing.expectEqualSlices(i32, &[_]i32{ 5, 4, 3, 2, 1 }, tailToHead);
}

test "LinkedList addFirst" {
    var allocator = std.testing.allocator;
    const List = LinkedList(i32);
    const Node = List.Node;
    var linkedList = List.init();
    defer linkedList.deinit();

    var node1 = Node{ .value = 1 };
    var node2 = Node{ .value = 2 };
    var node3 = Node{ .value = 3 };
    var node4 = Node{ .value = 4 };
    var node5 = Node{ .value = 5 };

    linkedList.addFirst(&node1);
    linkedList.addFirst(&node2);
    linkedList.addFirst(&node3);
    linkedList.addFirst(&node4);
    linkedList.addFirst(&node5);

    const headToTail = try linkedList.headToTailArray(allocator);
    defer allocator.free(headToTail);
    try testing.expectEqualSlices(i32, &[_]i32{ 5, 4, 3, 2, 1 }, headToTail);

    const tailToHead = try linkedList.tailToHeadArray(allocator);
    defer allocator.free(tailToHead);
    try testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5 }, tailToHead);
}

test "LinkedList addFirst addLast combination" {
    var allocator = std.testing.allocator;
    const List = LinkedList(i32);
    const Node = List.Node;
    var linkedList = List.init();
    defer linkedList.deinit();

    var node1 = Node{ .value = 1 };
    var node2 = Node{ .value = 2 };
    var node3 = Node{ .value = 3 };
    var node4 = Node{ .value = 4 };
    var node5 = Node{ .value = 5 };

    linkedList.addFirst(&node1);
    linkedList.addFirst(&node2);
    linkedList.addLast(&node3);
    linkedList.addLast(&node4);
    linkedList.addFirst(&node5);

    const headToTail = try linkedList.headToTailArray(allocator);
    defer allocator.free(headToTail);
    try testing.expectEqualSlices(i32, &[_]i32{ 5, 2, 1, 3, 4 }, headToTail);
}

fn expectLinkedListEqualSlice(comptime T: type, allocator: Allocator, linkedList: *LinkedList(T), expected: []const T) !void {
    const actual = try linkedList.headToTailArray(allocator);
    defer allocator.free(actual);
    try testing.expectEqualSlices(i32, expected, actual);
}

test {
    const allocator = std.testing.allocator;
    const List = LinkedList(i32);
    const Node = List.Node;
    var linkedList = List.init();
    defer linkedList.deinit();

    var node1 = Node{ .value = 1 };
    var node2 = Node{ .value = 2 };
    var node3 = Node{ .value = 3 };
    var node4 = Node{ .value = 4 };
    var node5 = Node{ .value = 5 };

    linkedList.addFirst(&node1);
    linkedList.addFirst(&node2);
    linkedList.addLast(&node3);
    linkedList.addFirst(&node4);
    linkedList.addLast(&node5);

    try expectLinkedListEqualSlice(i32, allocator, &linkedList, &[_]i32{ 4, 2, 1, 3, 5 });

    linkedList.detach(&node2);
    try expectLinkedListEqualSlice(i32, allocator, &linkedList, &[_]i32{ 4, 1, 3, 5 });

    linkedList.detach(&node4);
    try expectLinkedListEqualSlice(i32, allocator, &linkedList, &[_]i32{ 1, 3, 5 });

    linkedList.detach(&node5);
    try expectLinkedListEqualSlice(i32, allocator, &linkedList, &[_]i32{ 1, 3 });

    linkedList.detach(&node1);
    try expectLinkedListEqualSlice(i32, allocator, &linkedList, &[_]i32{3});

    linkedList.detach(&node3);
    try expectLinkedListEqualSlice(i32, allocator, &linkedList, &[_]i32{});
}
