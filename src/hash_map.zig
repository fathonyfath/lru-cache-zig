const std = @import("std");
const Allocator = std.mem.Allocator;
const autoHash = std.hash.autoHash;
const Wyhash = std.hash.Wyhash;
const linked_list = @import("./linked_list.zig");
const LinkedList = linked_list.LinkedList;
const eql = std.mem.eql;

pub fn HashMap(comptime K: type, comptime V: type) type {
    return struct {
        allocator: Allocator,
        array: []TypedLinkedList,

        const Pair = struct {
            key: K,
            value: V,
        };
        const TypedLinkedList = LinkedList(Pair);
        const Node = TypedLinkedList.Node;

        const Self = @This();
        const defaultStorageSize = 1;

        pub fn init(allocator: Allocator) !Self {
            const array = try allocator.alloc(TypedLinkedList, defaultStorageSize);
            @memset(array, TypedLinkedList.init());
            return Self{
                .allocator = allocator,
                .array = array,
            };
        }

        pub fn deinit(self: *Self) void {
            for (self.array) |item| {
                var current = item.head;
                while (current) |cur| {
                    current = cur.next;
                    self.allocator.destroy(cur);
                }
            }
            self.allocator.free(self.array);
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            const index = hash(key) % self.array.len;

            var list = &self.array[index];
            const listCurrent = list.head;
            // Check if we already have an item on the index. If so, meaning either it is
            // a hash collision, or updating value for a key.
            if (listCurrent) |current| {
                // Iterate the list, check if key already exist on list, if so update it.
                // If no key was found on the index, then add new node to the last of linked list.
                var cur: ?*Node = current;
                while (cur) |c| {
                    if (eql(K, &[1]K{c.value.key}, &[1]K{key})) {
                        // Early break meaning we found our node
                        break;
                    }
                    cur = c.next;
                }

                if (cur) |c| {
                    c.value.value = value;
                } else {
                    const node = try self.allocator.create(Node);
                    node.* = Node{
                        .value = Pair{ .key = key, .value = value },
                    };
                    list.addLast(node);
                }
            } else {
                const node = try self.allocator.create(Node);
                node.* = Node{
                    .value = Pair{ .key = key, .value = value },
                };
                list.addLast(node);
            }
        }

        pub fn get(self: *Self, key: K) ?V {
            const index = hash(key) % self.array.len;

            const list = &self.array[index];
            const head = list.head;

            if (head) |h| {
                var current: ?*Node = h;
                while (current) |cur| {
                    if (eql(K, &[1]K{cur.value.key}, &[1]K{key})) {
                        break;
                    }
                    current = cur.next;
                }

                if (current) |c| {
                    return c.value.value;
                } else {
                    return null;
                }
            } else {
                // We know that if head is null then linked list is empty
                return null;
            }
        }

        pub fn remove(self: *Self, key: K) bool {
            const index = hash(key) % self.array.len;

            var list = &self.array[index];
            const head = list.head;
            if (head) |h| {
                var current: ?*Node = h;
                while (current) |cur| {
                    if (eql(K, &[1]K{cur.value.key}, &[1]K{key})) {
                        break;
                    }
                    current = cur.next;
                }

                if (current) |n| {
                    list.detach(n);
                    self.allocator.destroy(n);
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        fn hash(key: K) u64 {
            var hasher = Wyhash.init(0);
            autoHash(&hasher, key);
            return hasher.final();
        }
    };
}

test "HashMap test empty map" {
    const allocator = std.testing.allocator;

    var hashMap = try HashMap(i32, i32).init(allocator);
    defer hashMap.deinit();

    try std.testing.expectEqual(null, hashMap.get(6));
}

test "HashMap test put, get" {
    const allocator = std.testing.allocator;

    var hashMap = try HashMap(i32, i32).init(allocator);
    defer hashMap.deinit();

    try hashMap.put(6, 32);
    try std.testing.expectEqual(32, hashMap.get(6));
}

test "HashMap test put, get, delete" {
    const allocator = std.testing.allocator;

    var hashMap = try HashMap(i32, i32).init(allocator);
    defer hashMap.deinit();

    try hashMap.put(6, 32);
    try std.testing.expectEqual(32, hashMap.get(6));

    try std.testing.expect(hashMap.remove(6));
    try std.testing.expectEqual(null, hashMap.get(6));
}

test "HashMap test put replace" {
    const allocator = std.testing.allocator;

    var hashMap = try HashMap(i32, i32).init(allocator);
    defer hashMap.deinit();

    try hashMap.put(6, 32);
    try std.testing.expectEqual(32, hashMap.get(6));
    try hashMap.put(7, 109);
    try std.testing.expectEqual(109, hashMap.get(7));

    try hashMap.put(6, 100);
    try std.testing.expectEqual(100, hashMap.get(6));
    try std.testing.expectEqual(109, hashMap.get(7));
}
