const std = @import("std");

const raylib_build = @import("raylib_build.zig");
const box2c_build = @import("box2c_build.zig");
const demo_build = @import("demo_build.zig");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{
        // For best performance
        .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast,

        // For best binary size
        // .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseSmall,
    });

    const raylib_build_cmd_step = raylib_build.build(b);

    const box2c_lib = box2c_build.build(b, target, optimize, raylib_build_cmd_step);
    demo_build.build(b, target, optimize, box2c_lib);
}
