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
    exe.addIncludePath(.{ .path = "/home/wison/c/raylib/zig-out/include" });
    exe.addObjectFile(.{ .path = "/home/wison/c/raylib/zig-out/lib/libraylib.a" });
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    // run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run-" ++ binary_name, "Run the " ++ binary_name ++ " demo");
    run_step.dependOn(&run_cmd.step);
}

///
///
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
        "click-to-generate-dynamic-boxes",
        "src/click-to-generate-dynamic-boxes.zig",
    );
}
