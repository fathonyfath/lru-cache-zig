const std = @import("std");
const Allocator = std.mem.Allocator;

const lru_cache = @import("lru_cache.zig");
const LRUCache = lru_cache.LRUCache;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var cache = LRUCache.init(allocator, 5);
    defer cache.deinit();
}
