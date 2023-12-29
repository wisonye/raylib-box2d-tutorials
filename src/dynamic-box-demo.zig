const b = @cImport({
    @cInclude("box2d/box2d.h");
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

    var dynamic_box_list = try std.ArrayList(DynamicBox).initCapacity(allocator, 500);

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
        // ---------------------------------------------------------------
        // Game logic
        // ---------------------------------------------------------------

        //
        // Press `Q` to exit
        //
        if (rl.IsKeyPressed(rl.KEY_Q)) {
            is_running = false;
            rl.TraceLog(rl.LOG_INFO, ">>> Press 'Q' to exit");
        }

        //
        // Press 'R' to reset camera origin to world's origin
        //
        if (rl.IsKeyPressed(rl.KEY_R)) {
            camera.reset_origin_to_world_origin(true);
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
        // Move camera target (world's coordinate) by mouse movement delta
        //
        if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_RIGHT)) {
            camera.move_target_by_mouse_delta_position(rl.GetMouseDelta());
        }

        //
        // Zoom in/out at current mouse position
        //
        const mouse_wheel_movement = rl.GetMouseWheelMove();
        if (mouse_wheel_movement != 0.0) {
            camera.zoom_at_mouse_position(mouse_wheel_movement);
        }

        //
        // Press down mouse left button to generate new dynamic body
        //
        if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) {
            const mouse_pos = rl.GetMousePosition();
            const screen_to_world_pos = camera.screen_to_world_pos(mouse_pos);

            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> [ main loop ] - mouse pos: (%.2f, %.2f), screen_to_world_pos: { %.2f, %.2f}",
                mouse_pos.x,
                mouse_pos.y,
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

        // ---------------------------------------------------------------
        // Redraw frame
        // ---------------------------------------------------------------
        rl.BeginDrawing();
        rl.ClearBackground(Game.Color.TRON_DARK);

        //
        // 2D Camera mode
        //
        rl.BeginMode2D(camera._internal_camera);

        // Draw ground box
        world.redraw_ground_box();

        // Draw all dynamic boxes
        for (dynamic_box_list.items) |box| {
            box.redraw();
        }

        rl.EndMode2D();

        //
        // Draw left-top tips
        //
        const title_font_size = @as(f32, @floatFromInt(my_font.baseSize)) * 1.3;
        const font_size = @as(f32, @floatFromInt(my_font.baseSize)) * 0.8;
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
            "- Hold down mouse left button to emit dynamic boxes",
            .{ .x = 30.0, .y = 80.0 },
            font_size,
            2.0,
            Game.Color.TRON_BLUE,
        );

        rl.DrawTextEx(
            my_font,
            "- Hold down mouse right button and drag to move camera",
            .{ .x = 30.0, .y = 100.0 },
            font_size,
            2.0,
            Game.Color.TRON_BLUE,
        );

        rl.DrawTextEx(
            my_font,
            "- Mouse wheel to zoom in/out",
            .{ .x = 30.0, .y = 120.0 },
            font_size,
            2.0,
            Game.Color.TRON_BLUE,
        );

        rl.DrawTextEx(
            my_font,
            "- 'R' to reset camera",
            .{ .x = 30.0, .y = 140.0 },
            font_size,
            2.0,
            Game.Color.TRON_BLUE,
        );

        var msg_buffer = [_]u8{0x00} ** 256;
        const msg = std.fmt.bufPrint(
            &msg_buffer,
            "- Dynamic boxes count: {d}",
            .{dynamic_box_list.items.len},
        ) catch "";
        rl.DrawTextEx(
            my_font,
            @as([*c]const u8, @ptrCast(msg)),
            .{ .x = 30.0, .y = 160.0 },
            font_size,
            2.0,
            Game.Color.TRON_YELLOW,
        );

        rl.EndDrawing();
    }
}
