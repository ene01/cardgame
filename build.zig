const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // lib
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "cardgame",
        .linkage = .static,
        .root_module = lib_mod,
    });

    // dependencies
    const zeit_dep = b.dependency("zeit", .{
        .target = target,
        .optimize = optimize,
    });

    // tests
    const full_test = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const log_test = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/log.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // imports
    lib.root_module.addImport("zeit", zeit_dep.module("zeit"));

    log_test.root_module.addImport("zeit", zeit_dep.module("zeit"));
    log_test.root_module.addImport("cardgame", lib_mod);

    full_test.root_module.addImport("zeit", zeit_dep.module("zeit"));
    full_test.root_module.addImport("cardgame", lib_mod);

    // run
    const run_log_tests = b.addRunArtifact(log_test);
    const run_full_tests = b.addRunArtifact(full_test);

    b.step("log-test", "Run unit tests").dependOn(&run_log_tests.step);
    b.step("full-test", "Run unit tests").dependOn(&run_full_tests.step);

    // installs
    b.installArtifact(lib);
}
