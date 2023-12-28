const rl = @cImport({
    @cInclude("raylib.h");
});

const GAME_FPS = 60;

const TRON_DARK = rl.Color{ .r = 0x23, .g = 0x21, .b = 0x1B, .a = 0xFF };
const TRON_LIGHT_BLUE = rl.Color{ .r = 0xAC, .g = 0xE6, .b = 0xFE, .a = 0xFF };
const TRON_BLUE = rl.Color{ .r = 0x6F, .g = 0xC3, .b = 0xDF, .a = 0xFF };
const TRON_YELLOW = rl.Color{ .r = 0xFF, .g = 0xE6, .b = 0x4D, .a = 0xFF };
const TRON_ORANGE = rl.Color{ .r = 0xFF, .g = 0x9F, .b = 0x1C, .a = 0xFF };
const TRON_RED = rl.Color{ .r = 0xF4, .g = 0x47, .b = 0x47, .a = 0xFF };

///
///
///
pub fn main() !void {
    // Create a window with a particular size and title
    rl.InitWindow(1024, 768, "How to draw images and textures");
    defer rl.CloseWindow();

    // Set refresh rate (AKA, FPS: Frame Per Second)
    rl.SetTargetFPS(GAME_FPS);

    // Set tracing log level (DEBUG/INFO/WARN/ERROR)
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    // Hide the cursor
    // rl.HideCursor();

    // Optional, enable waiting for events (keyboard/mouse/etc) on `EndDrawing()`,
    // no automatic event polling, save power consumsion.
    // rl.EnableEventWaiting();

    //
    // Load image texture
    //
    var laser_sword_image = rl.LoadImage("resources/textures/blue_laser.png");
    rl.ImageResize(@as([*c]rl.Image, @ptrCast(&laser_sword_image)), 20, 100);
    const laser_sword_texture: ?rl.Texture2D = rl.LoadTextureFromImage(laser_sword_image);
    rl.UnloadImage(laser_sword_image);

    //
    // Lightning ball
    //
    var lightning_ball_image: rl.Image = rl.LoadImage("resources/textures/lightning_ball.png");
    rl.ImageResize(@as([*c]rl.Image, @ptrCast(&lightning_ball_image)), 100, 100);
    const lightning_ball_texture: ?rl.Texture2D = rl.LoadTextureFromImage(lightning_ball_image);
    rl.UnloadImage(lightning_ball_image);

    //
    // Game loop
    //
    var is_running = true;
    while (is_running) {
        // -------------------------------------------------------------
        // Game logic
        // -------------------------------------------------------------

        //
        // Press `Q` to exit
        //
        if (rl.IsKeyPressed(rl.KEY_Q)) {
            is_running = false;
            rl.TraceLog(rl.LOG_DEBUG, ">>> Press 'Q' to exit");
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
        // Print mouse position when pressing left button
        //
        if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
            const mouse_pos = rl.GetMousePosition();
            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> Mouse position: { x: %.2f, y: %.2f }",
                mouse_pos.x,
                mouse_pos.y,
            );
        }

        // -------------------------------------------------------------
        // Redraw the entire frame
        // -------------------------------------------------------------
        rl.BeginDrawing();

        // Clear background
        rl.ClearBackground(TRON_DARK);

        // Draw image texture
        if (laser_sword_texture) |texture| {
            rl.DrawTexturePro(
                texture,
                // Texture rect to draw from
                rl.Rectangle{
                    .x = 0.0,
                    .y = 0.0,
                    .width = @as(f32, @floatFromInt(texture.width)),
                    .height = @as(f32, @floatFromInt(texture.height)),
                },
                // Target rect to draw (orgin is TopLeft by default!!!)
                rl.Rectangle{
                    .x = 20.0,
                    .y = 20.0,
                    .width = @as(f32, @floatFromInt(texture.width)),
                    .height = @as(f32, @floatFromInt(texture.height)),
                },
                // Origin offset of the target rect to draw (TopLeft by default)
                rl.Vector2{ .x = 0.0, .y = 0.0 },
                0.0,
                TRON_LIGHT_BLUE,
            );
        }

        if (lightning_ball_texture) |texture| {
            rl.DrawTexturePro(
                texture,
                // Texture rect to draw from
                rl.Rectangle{
                    .x = 0.0,
                    .y = 0.0,
                    .width = @as(f32, @floatFromInt(texture.width)),
                    .height = @as(f32, @floatFromInt(texture.height)),
                },
                // Target rect to draw (orgin is TopLeft by default!!!)
                rl.Rectangle{
                    .x = 80.0,
                    .y = 20.0,
                    .width = @as(f32, @floatFromInt(texture.width)),
                    .height = @as(f32, @floatFromInt(texture.height)),
                },
                // Origin offset of the target rect to draw (TopLeft by default)
                rl.Vector2{ .x = 0.0, .y = 0.0 },
                0.0,
                TRON_LIGHT_BLUE,
            );
        }

        rl.EndDrawing();
    }

    //
    // Unload/clean up resources
    //
    if (laser_sword_texture) |value| rl.UnloadTexture(value);
    if (lightning_ball_texture) |value| rl.UnloadTexture(value);
}
