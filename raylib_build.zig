const std = @import("std");

///
/// Run `cd raylib && zig build`
///
pub fn build(
    b: *std.Build,
) *std.Build.Step {
    const zig_build_cmd = b.addSystemCommand(&[_][]const u8{ "zig", "build" });

    // Change working directory
    zig_build_cmd.cwd = .{ .path = "./raylib" };

    return &zig_build_cmd.step;
}
