const std = @import("std");
const Allocator = std.mem.Allocator;
const linked_list = @import("./linked_list.zig");
const LinkedList = linked_list.LinkedList;

/// Error definition for LRUCache
pub const LRUCacheError = error{NoElementFound};

/// Implementation of LRU Cache
pub const LRUCache = struct {
    allocator: Allocator,
    capacity: usize,

    const Self = @This();

    /// Create the LRU Cache
    pub fn init(allocator: Allocator, capacity: usize) Self {
        return Self{
            .allocator = allocator,
            .capacity = capacity,
        };
    }

    /// Destructor of LRU Cache
    /// Call this to clean up the memory used by this object
    pub fn deinit(self: *LRUCache) void {
        _ = self;
    }

    /// Returns a value of key exists on the cache
    /// If key is found on the cache, set the key-value pair to the top priority
    pub fn get(self: *LRUCache, key: i32) LRUCacheError!i32 {
        _ = self;
        _ = key;
    }

    /// Add the key-value pair to the cache
    /// If the key is already exists, update the value
    pub fn put(self: *LRUCache, key: i32, value: i32) !void {
        _ = self;
        _ = key;
        _ = value;
    }
};
