const std = @import("std");
const Allocator = std.mem.Allocator;
const linked_list = @import("./linked_list.zig");
const LinkedList = linked_list.LinkedList;

/// Error definition for LRUCache
pub const LRUCacheError = error{NoElementFound};

/// Implementation of LRU Cache
pub const LRUCache = struct {
    allocator: Allocator,
    count: usize = 0,
    capacity: usize,
    linkedList: *TypedLinkedList,

    const Self = @This();
    const Pair = struct {
        key: i32,
        value: i32,
    };
    const TypedLinkedList = LinkedList(Pair);
    const Node = TypedLinkedList.Node;

    /// Create the LRU Cache
    pub fn init(allocator: Allocator, capacity: usize) !Self {
        const list = try allocator.create(TypedLinkedList);
        list.* = TypedLinkedList.init();
        return Self{
            .allocator = allocator,
            .count = 0,
            .capacity = capacity,
            .linkedList = list,
        };
    }

    /// Destructor of LRU Cache
    /// Call this to clean up the memory used by this object
    pub fn deinit(self: *LRUCache) void {
        var current = self.linkedList.head;
        while (current) |cur| {
            current = cur.next;
            self.allocator.destroy(cur);
        }
        self.allocator.destroy(self.linkedList);
    }

    /// Returns a value of key exists on the cache
    /// If key is found on the cache, set the key-value pair to the top priority
    pub fn get(self: *LRUCache, key: i32) LRUCacheError!i32 {
        var found_node: ?*Node = null;
        var current = self.linkedList.head;
        while (current) |cur| {
            if (cur.value.key == key) {
                found_node = cur;
                break;
            }
            current = cur.next;
        }

        if (found_node) |found| {
            self.linkedList.detach(found);
            self.linkedList.addFirst(found);
            return found.value.value;
        } else {
            return LRUCacheError.NoElementFound;
        }
    }

    /// Add the key-value pair to the cache
    /// If the key is already exists, update the value
    pub fn put(self: *LRUCache, key: i32, value: i32) !void {
        var found_node: ?*Node = null;
        var current = self.linkedList.head;
        while (current) |cur| {
            if (cur.value.key == key) {
                found_node = cur;
                break;
            }
            current = cur.next;
        }

        if (found_node) |found| {
            found.value.value = value;
            self.linkedList.detach(found);
            self.linkedList.addFirst(found);
        } else {
            const node = try self.allocator.create(Node);
            node.* = Node{
                .value = Pair{ .key = key, .value = value },
            };

            self.linkedList.addFirst(node);
            if (self.count + 1 > self.capacity) {
                const tail = self.linkedList.tail.?;
                self.linkedList.detach(tail);
                self.allocator.destroy(tail);
            } else {
                self.count += 1;
            }
        }
    }
};

test {
    const testing = std.testing;
    const allocator = testing.allocator;

    var lruCache = try LRUCache.init(allocator, 2);
    defer lruCache.deinit();

    try lruCache.put(1, 1); // cache is {1=>1}
    try lruCache.put(2, 2); // cache is {2=>2, 1=>1}
    try testing.expectEqual(1, try lruCache.get(1)); // returns 1, cache become {1=>1, 2=>2}
    try lruCache.put(3, 3); // since key 2 was least recently used, evicts 2, become {3=>3, 1=>1}
    try testing.expectError(LRUCacheError.NoElementFound, lruCache.get(2)); // should return LRUCacheError.NoElementFound
    try lruCache.put(4, 4); // since key 1 was least recently used, evicts 1, become {4=>4, 3=>3}
    try testing.expectError(LRUCacheError.NoElementFound, lruCache.get(1)); // should return LRUCacheError.NoElementFound
    try testing.expectEqual(3, try lruCache.get(3)); // returns 3, cache become {3=>3, 4=>4}
    try testing.expectEqual(4, try lruCache.get(4)); // returns 4, cache become {4=>4, 3=>3}
}
