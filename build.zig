const std = @import("std");

const test_targets = [_]std.Target.Query{
    .{}, // native
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const exe = b.addExecutable(.{
        .name = "renderer",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize
        })
    }
    );

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run renderer");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");

    for (test_targets) |test_target| {
        const unit_tests = b.addTest(.{
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/tests.zig"),
                .target = b.resolveTargetQuery(test_target)
            })
        });

        unit_tests.root_module.addImport("raylib", raylib);
        unit_tests.linkLibrary(raylib_artifact);

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);
    }

    b.installArtifact(exe);
}