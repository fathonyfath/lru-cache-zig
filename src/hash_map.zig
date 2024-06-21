const std = @import("std");

pub fn HashMap(comptime K: type, comptime V: type) type {
    return struct {
        pub fn put(key: K, value: V) !void {
            _ = key;
            _ = value;
        }

        pub fn get(key: K) ?V {
            _ = key;
        }

        pub fn remove(key: K) bool {
            _ = key;
        }
    };
}

test {}
