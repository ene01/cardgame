const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // options
    const file_test = b.option([]const u8, "test", "File to test") orelse "";

    // dependencies
    const zeit_dep = b.dependency("zeit", .{
        .target = target,
        .optimize = optimize,
    });

    // tests
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path(file_test),
            .target = target,
            .optimize = optimize,
        }),
    });

    // imports
    tests.root_module.addImport("zeit", zeit_dep.module("zeit"));

    // runs
    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Run unit tests from a file").dependOn(&run_tests.step);
}
