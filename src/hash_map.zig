const std = @import("std");
const Allocator = std.mem.Allocator;
const autoHash = std.hash.autoHash;
const Wyhash = std.hash.Wyhash;

pub fn HashMap(comptime K: type, comptime V: type) type {
    return struct {
        allocator: Allocator,
        array: []?V,

        const Self = @This();
        const defaultStorageSize = 1000;

        pub fn init(allocator: Allocator) !Self {
            const array = try allocator.alloc(?V, defaultStorageSize);
            @memset(array, null);
            return Self{
                .allocator = allocator,
                .array = array,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.array);
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            const index = hash(key) % self.array.len;
            self.array[index] = value;
        }

        pub fn get(self: *Self, key: K) ?V {
            const index = hash(key) % self.array.len;
            return self.array[index];
        }

        pub fn remove(self: *Self, key: K) bool {
            const index = hash(key) % self.array.len;
            const value = self.array[index];
            if (value) |_| {
                self.array[index] = null;
                return true;
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

    try hashMap.put(6, 100);
    try std.testing.expectEqual(100, hashMap.get(6));
}
