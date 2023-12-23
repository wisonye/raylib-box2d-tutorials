const std = @import("std");

///
///
///
pub fn build(
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
    box2c_lib: *std.build.Step.Compile,
) void {
    const test_world = b.addExecutable(.{
        .name = "test_world",
        .root_source_file = .{ .path = "src/test_world.zig" },
        .target = target,
        .optimize = optimize,
    });

    test_world.addIncludePath(.{ .path = "box2c/include" });
    test_world.linkLibrary(box2c_lib);
    test_world.linkSystemLibrary("m");
    b.installArtifact(test_world);

    const run_test_world_cmd = b.addRunArtifact(test_world);
    run_test_world_cmd.step.dependOn(b.getInstallStep());
    const run_test_world_step = b.step("run-test-world", "Run the test world");
    run_test_world_step.dependOn(&run_test_world_cmd.step);
}
