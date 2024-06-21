const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "lru-cache-zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");

    registerTest(b, test_step, .{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    registerTest(b, test_step, .{
        .name = "lru_cache",
        .root_source_file = b.path("src/lru_cache.zig"),
        .target = target,
        .optimize = optimize,
    });

    registerTest(b, test_step, .{
        .name = "linked_list",
        .root_source_file = b.path("src/linked_list.zig"),
        .target = target,
        .optimize = optimize,
    });

    registerTest(b, test_step, .{
        .name = "hash_map",
        .root_source_file = b.path("src/hash_map.zig"),
        .target = target,
        .optimize = optimize,
    });
}

fn registerTest(b: *std.Build, test_step: *std.Build.Step, options: std.Build.TestOptions) void {
    const unit_tests = b.addTest(options);
    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);
}
