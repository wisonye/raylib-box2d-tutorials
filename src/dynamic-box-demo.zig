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
    Game.init(1024, 768, "[ Raylib Box2D Demo ] - Dynamic box");
    defer Game.deinit();

    //
    // Load custom font
    //
    const my_font = rl.LoadFont("resources/fonts/SauceCodeProNerdFont-Medium.ttf");
    defer rl.UnloadFont(my_font);

    //
    // Create 2D camera
    //
    var camera = Camera2D.init(
        @as(usize, @intCast(rl.GetScreenWidth())),
        @as(usize, @intCast(rl.GetScreenHeight())),
        Game.PIXEL_TO_WORLD_SCALE_FACTOR,
    );

    //
    // Create Box2D world and static ground box
    //
    var world = World.init();
    try world.create_static_ground_box(
        .{ .x = 0.0, .y = 0.0 },
        50.0,
        1.0,
        null,
        null,
        null,
    );
    defer world.deinit();

    //
    // Create bunch of dynamic boxes
    //
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("\nGPA detected a memory leak!!!\n");
    }

    var dynamic_box_list = try std.ArrayList(DynamicBox).initCapacity(allocator, 100);

    // Create 10 dynamic boxes: 1x1 meter box at init position 40 meters height
    for (1..11) |index| {
        try dynamic_box_list.append(try DynamicBox.init(
            &world,
            &camera,
            .{ .x = 0.0, .y = @floatFromInt(index * 10) },
            1.0,
            1.0,
            null,
            null,
            null,
            null,
            null,
        ));
    }

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
        // Press `D` to generate new dynamic body
        //
        if (rl.IsKeyPressed(rl.KEY_D)) {
            const mouse_pos = rl.GetMousePosition();
            rl.TraceLog(
                rl.LOG_INFO,
                ">>> Mouse clicked at : (%.2f, %.2f)",
                mouse_pos.x,
                mouse_pos.y,
            );

            const screen_to_world_pos = camera.screen_to_world_pos(mouse_pos);

            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> [ main loop ] - screen_to_world_pos: { %.2f, %.2f}",
                screen_to_world_pos.x,
                screen_to_world_pos.y,
            );
            try dynamic_box_list.append(try DynamicBox.init(
                &world,
                &camera,
                .{
                    .x = screen_to_world_pos.x,
                    .y = screen_to_world_pos.y,
                },
                1.0,
                1.0,
                null,
                null,
                null,
                Game.Color.TRON_RED,
                Game.Color.TRON_DARK,
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

        const title_font_size = @as(f32, @floatFromInt(my_font.baseSize)) * 1.3;
        const font_size = @as(f32, @floatFromInt(my_font.baseSize)) * 0.9;
        rl.DrawTextEx(
            my_font,
            "Raylib Box2D Demo",
            .{ .x = 20.0, .y = 20.0 },
            title_font_size,
            2.0,
            Game.Color.TRON_BLUE,
        );
        rl.DrawTextEx(
            my_font,
            "- 'D' to drop a dynamic box at the mouse position",
            .{ .x = 30.0, .y = 80.0 },
            font_size,
            2.0,
            Game.Color.TRON_LIGHT_BLUE,
        );
        rl.DrawTextEx(
            my_font,
            "- Mouse wheel to scale camera view",
            .{ .x = 30.0, .y = 110.0 },
            font_size,
            2.0,
            Game.Color.TRON_LIGHT_BLUE,
        );

        rl.EndDrawing();
    }
}
