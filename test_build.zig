const std = @import("std");

///
///
///
pub fn build(
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const test_world = b.addExecutable(.{
        .name = "test_world",
        .root_source_file = .{ .path = "src/test_world.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(test_world);

    const run_test_world_cmd = b.addRunArtifact(test_world);
    run_test_world_cmd.step.dependOn(b.getInstallStep());
    const run_test_world_step = b.step("run-test-world", "Run the test world");
    run_test_world_step.dependOn(&run_test_world_cmd.step);
}
