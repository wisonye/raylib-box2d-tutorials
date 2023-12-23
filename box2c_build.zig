const std = @import("std");

///
/// Compile `Box2C` into static library
///
pub fn build(
    b: *std.Build,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) *std.build.Step.Compile {
    // const simde_lib = b.addStaticLibrary(.{
    //     .name = "simde",
    //     .root_source_file = null,
    //     .target = target,
    //     .optimize = optimize,
    // });

    // //
    // // Compile from C source files
    // //
    // simde_lib.addCSourceFiles(.{
    //     .flags = &[_][]const u8{
    //         "-std=gnu17",
    //         "-Wall",
    //         "-Wextra",
    //         "-Wpedantic",
    //         "-Werror",
    //         "-mavx",
    //     },
    //     .files = &[_][]const u8{
    //         "box2c/extern/simde/check.h",
    //         "box2c/extern/simde/debug-trap.h",
    //         "box2c/extern/simde/hedley.h",
    //         "box2c/extern/simde/simde-aes.h",
    //         "box2c/extern/simde/simde-align.h",
    //         "box2c/extern/simde/simde-arch.h",
    //         "box2c/extern/simde/simde-bf16.h",
    //         "box2c/extern/simde/simde-common.h",
    //         "box2c/extern/simde/simde-complex.h",
    //         "box2c/extern/simde/simde-constify.h",
    //         "box2c/extern/simde/simde-detect-clang.h",
    //         "box2c/extern/simde/simde-diagnostic.h",
    //         "box2c/extern/simde/simde-f16.h",
    //         "box2c/extern/simde/simde-features.h",
    //         "box2c/extern/simde/simde-math.h",
    //         "box2c/extern/simde/x86/aes.h",
    //         "box2c/extern/simde/x86/avx.h",
    //         "box2c/extern/simde/x86/avx2.h",
    //         "box2c/extern/simde/x86/f16c.h",
    //         "box2c/extern/simde/x86/fma.h",
    //         "box2c/extern/simde/x86/mmx.h",
    //         "box2c/extern/simde/x86/sse.h",
    //         "box2c/extern/simde/x86/sse2.h",
    //         "box2c/extern/simde/x86/sse3.h",
    //         "box2c/extern/simde/x86/sse4.1.h",
    //         "box2c/extern/simde/x86/sse4.2.h",
    //         "box2c/extern/simde/x86/ssse3.h",
    //     },
    // });
    // simde_lib.linkLibC();

    const box2c_lib = b.addStaticLibrary(.{
        .name = "box2c",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    //
    // Compile from C source files
    //
    box2c_lib.addCSourceFiles(.{
        .flags = &[_][]const u8{
            "-std=gnu17",
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-Werror",
            "-mavx",
        },
        .files = &[_][]const u8{
            "box2c/src/aabb.c",
            "box2c/src/allocate.c",
            "box2c/src/allocate.h",
            "box2c/src/array.c",
            "box2c/src/array.h",
            "box2c/src/bitset.c",
            "box2c/src/bitset.h",
            "box2c/src/block_allocator.c",
            "box2c/src/block_allocator.h",
            "box2c/src/body.c",
            "box2c/src/body.h",
            "box2c/src/broad_phase.c",
            "box2c/src/broad_phase.h",
            "box2c/src/contact.c",
            "box2c/src/contact.h",
            "box2c/src/contact_solver.c",
            "box2c/src/contact_solver.h",
            "box2c/src/core.c",
            "box2c/src/core.h",
            "box2c/src/distance.c",
            "box2c/src/distance_joint.c",
            "box2c/src/dynamic_tree.c",
            "box2c/src/geometry.c",
            "box2c/src/graph.c",
            "box2c/src/graph.h",
            "box2c/src/hull.c",
            "box2c/src/island.c",
            "box2c/src/island.h",
            "box2c/src/joint.c",
            "box2c/src/joint.h",
            "box2c/src/manifold.c",
            "box2c/src/math.c",
            "box2c/src/mouse_joint.c",
            "box2c/src/polygon_shape.h",
            "box2c/src/pool.c",
            "box2c/src/pool.h",
            "box2c/src/prismatic_joint.c",
            "box2c/src/revolute_joint.c",
            "box2c/src/shape.c",
            "box2c/src/shape.h",
            "box2c/src/solver_data.h",
            "box2c/src/stack_allocator.c",
            "box2c/src/stack_allocator.h",
            "box2c/src/table.c",
            "box2c/src/table.h",
            "box2c/src/timer.c",
            "box2c/src/types.c",
            "box2c/src/weld_joint.c",
            "box2c/src/world.c",
            "box2c/src/world.h",
        },
    });
    box2c_lib.addIncludePath(.{ .path = "box2c/include" });
    box2c_lib.addIncludePath(.{ .path = "box2c/extern/simde" });
    // box2c_lib.linkLibrary(simde_lib);
    box2c_lib.linkSystemLibrary("m");

    b.installArtifact(box2c_lib);

    return box2c_lib;
}
