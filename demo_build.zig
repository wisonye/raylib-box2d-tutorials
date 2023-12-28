const std = @import("std");

///
///
///
pub fn create_demo_binary_and_test_step(
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
    box2c_lib: *std.build.Step.Compile,
    comptime binary_name: []const u8,
    comptime source_filename: []const u8,
) void {
    const exe = b.addExecutable(.{
        .name = binary_name,
        .root_source_file = .{ .path = source_filename },
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(.{ .path = "box2c/include" });
    exe.linkLibrary(box2c_lib);
    exe.linkSystemLibrary("m");
    exe.addIncludePath(.{ .path = "raylib/zig-out/include" });
    exe.addObjectFile(.{ .path = "raylib/zig-out/lib/libraylib.a" });
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    // run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run-" ++ binary_name, "Run the " ++ binary_name ++ " demo");
    run_step.dependOn(&run_cmd.step);
}

///
/// Compile all demo binaries
///
pub fn build(
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
    box2c_lib: *std.build.Step.Compile,
) void {
    create_demo_binary_and_test_step(
        b,
        target,
        optimize,
        box2c_lib,
        "dynamic-box",
        "src/dynamic-box-demo.zig",
    );

    create_demo_binary_and_test_step(
        b,
        target,
        optimize,
        box2c_lib,
        "temp-test",
        "src/temp_test.zig",
    );

    // --------------------------------------------------------------
    // Camera test examples
    // --------------------------------------------------------------
    create_demo_binary_and_test_step(
        b,
        target,
        optimize,
        box2c_lib,
        "centre-with-player-position",
        "src/camera_examples/2d/centre-with-player-position.zig",
    );

    create_demo_binary_and_test_step(
        b,
        target,
        optimize,
        box2c_lib,
        "move-and-zoom-by-mouse",
        "src/camera_examples/2d/move-and-zoom-by-mouse.zig",
    );

    create_demo_binary_and_test_step(
        b,
        target,
        optimize,
        box2c_lib,
        "first-person-view",
        "src/camera_examples/3d/first-person-view.zig",
    );
}
