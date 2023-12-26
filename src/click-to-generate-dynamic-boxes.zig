const b = @cImport({
    @cInclude("box2d/box2d.h");
    @cInclude("stdio.h");
});

const rl = @cImport({
    @cInclude("raylib.h");
});

const std = @import("std");
const World = @import("utils/world.zig");
const Camera2D = @import("utils/camera_2d.zig");
const DynamicBox = @import("utils/dynamic_box.zig");
const Game = @import("utils/game.zig");

///
///
///
pub fn main() !void {
    //
    // Raylib game init
    //
    Game.init(1024, 768, "Raylib Box2D Demo: Click to generate dynamic boxes");
    defer Game.deinit();

    //
    // Create 2D camera
    //
    var camera = Camera2D.init(
        @as(usize, @intCast(rl.GetScreenWidth())),
        @as(usize, @intCast(rl.GetScreenHeight())),
    );

    //
    // Create Box2D world and static ground box
    //
    var world = World.init();
    try world.create_static_ground_box(.{ .x = 0.0, .y = 0.0 }, 50.0, 2.0);
    defer world.deinit();

    //
    // Create bunch of dynamic box
    //
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("\nGPA detected a memory leak!!!\n");
    }

    var dynamic_box_list = try std.ArrayList(DynamicBox).initCapacity(allocator, 100);
    try dynamic_box_list.appendSlice(&[_]DynamicBox{
        try DynamicBox.init(&world, &camera, .{ .x = 0.0, .y = 10.0 }, 1.0, 1.0, null, null, null),
        try DynamicBox.init(&world, &camera, .{ .x = 2.0, .y = 20.0 }, 1.0, 1.0, null, null, null),
        try DynamicBox.init(&world, &camera, .{ .x = 3.0, .y = 30.0 }, 1.0, 1.0, null, null, null),
        try DynamicBox.init(&world, &camera, .{ .x = 4.0, .y = 40.0 }, 1.0, 1.0, null, null, null),
    });
    defer dynamic_box_list.deinit();

    //
    // Game loop
    //
    var is_running = true;

    while (is_running) {
        // rl.TraceLog(rl.LOG_INFO, ">>> Redraw .....");

        //
        // Press `Q` to exit
        //
        if (rl.IsKeyPressed(rl.KEY_Q)) {
            is_running = false;
            rl.TraceLog(rl.LOG_INFO, ">>> Press 'Q' to exit");
        }

        //
        // If the window gets resized, we need to update the camera
        //
        if (rl.IsWindowResized()) {
            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> New width: %d, new height: %d",
                rl.GetScreenWidth(),
                rl.GetScreenHeight(),
            );
        }

        //
        // If wheel move change, then update the camera zoom settings
        //
        const current_wheel_move_y = rl.GetMouseWheelMoveV().y;
        if (current_wheel_move_y != 0.0) {
            const current_zoom = camera.get_zoom();
            camera.set_zoom(current_zoom + current_wheel_move_y * 0.05);
        }

        //
        // Press `G` to generate new dynamic body
        //
        if (rl.IsKeyPressed(rl.KEY_G)) {
            const mouse_pos = rl.GetMousePosition();
            rl.TraceLog(
                rl.LOG_INFO,
                ">>> Mouse clicked at : (%.2f, %.2f)",
                mouse_pos.x,
                mouse_pos.y,
            );

            const current_camera_zoom = camera.get_zoom();
            try dynamic_box_list.append(try DynamicBox.init(
                &world,
                &camera,
                .{
                    .x = (mouse_pos.x - @as(f32, @floatFromInt(rl.GetScreenWidth())) / 2.0) * Game.PIXEL_TO_WORLD_SCALE_FACTOR / current_camera_zoom,
                    .y = ((mouse_pos.y - @as(f32, @floatFromInt(rl.GetScreenHeight())) / 2.0) * Game.PIXEL_TO_WORLD_SCALE_FACTOR) / current_camera_zoom * -1.0,
                },
                1.0,
                1.0,
                null,
                null,
                null,
            ));
        }

        try world.run_simulation_step();

        //
        // Redraw everything
        //
        rl.BeginDrawing();
        rl.ClearBackground(Game.Color.TRON_DARK);

        rl.BeginMode2D(camera._internal_camera);

        world.redraw_ground_box();

        for (dynamic_box_list.items) |box| {
            box.redraw();
        }

        rl.EndMode2D();

        rl.DrawText("Raylib Box2D Demo", 20.0, 20.0, 30.0, Game.Color.TRON_LIGHT_BLUE);
        rl.DrawText("- Press 'G' to create a dynamic box at the mouse position", 40.0, 80.0, 20.0, Game.Color.TRON_YELLOW);
        rl.DrawText("- Mouse wheel to scale camera view", 40.0, 100.0, 20.0, Game.Color.TRON_YELLOW);

        rl.EndDrawing();
    }
}
