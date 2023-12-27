const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
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
    //
    // Enable `multisample anti-aliasing (MSAA)` to get better smoother edge rendering
    //
    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT);

    //
    // Create a window with a particular size and title
    //
    const screen_width: c_int = 1024;
    const screen_height: c_int = 768;
    rl.InitWindow(screen_width, screen_height, "Camera 2D move and zoom by mouse");
    defer rl.CloseWindow();

    // Set refresh rate (AKA, FPS: Frame Per Second)
    rl.SetTargetFPS(GAME_FPS);

    // Set tracing log level (DEBUG/INFO/WARN/ERROR)
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    //
    // Setup camera
    //
    const default_camera_zoom = 1.0;
    var camera = rl.Camera2D{
        //
        // Camera/window origin in screen coordinate, set to center of the screen,
        // used for zooming and rotating
        //
        .offset = .{
            .x = @as(f32, @floatFromInt(screen_width)) / 2.0,
            .y = @as(f32, @floatFromInt(screen_height)) / 2.0,
        },
        // .offset = .{ .x = 0.0, .y = 0.0 },
        .rotation = 0.0,
        .zoom = default_camera_zoom,
        //
        // World space point map to the camera/window origin
        //
        .target = .{ .x = 0.0, .y = 0.0 },
    };

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
        // Translate based on mouse right click
        //
        if (rl.IsMouseButtonDown(rl.MOUSE_BUTTON_LEFT)) {
            var delta = rl.GetMouseDelta();
            delta = rl.Vector2Scale(delta, -1.0 / camera.zoom);

            camera.target = rl.Vector2Add(camera.target, delta);
        }

        //
        // Zoom based on mouse wheel
        //
        const wheel = rl.GetMouseWheelMove();
        if (wheel != 0.0) {
            // Get the world point that is under the mouse
            const mouseWorldPos = rl.GetScreenToWorld2D(rl.GetMousePosition(), camera);

            // Set the offset to where the mouse is
            camera.offset = rl.GetMousePosition();

            // Set the target to match, so that the camera maps the world space point
            // under the cursor to the screen space point under the cursor at any zoom
            camera.target = mouseWorldPos;

            // Zoom increment
            const zoomIncrement: f32 = 0.125;

            camera.zoom += (wheel * zoomIncrement);
            if (camera.zoom < zoomIncrement) {
                camera.zoom = zoomIncrement;
            }
        }

        // -------------------------------------------------------------
        // Redraw the entire frame
        // -------------------------------------------------------------
        rl.BeginDrawing();

        rl.ClearBackground(TRON_DARK);

        rl.BeginMode2D(camera);

        //
        // Draw world centre lines
        //
        rl.DrawLineV(
            .{ .x = -1000.0, .y = 0.0 },
            .{ .x = 1000.0, .y = 0.0 },
            TRON_LIGHT_BLUE,
        );
        rl.DrawLineV(
            .{ .x = 0.0, .y = 1000.0 },
            .{ .x = 0.0, .y = -1000.0 },
            TRON_LIGHT_BLUE,
        );

        //
        // Draw world centre lines positive direction indicator and '+' sign
        //
        const poly_shape_sides = 3; // Means triangle
        const poly_shape_radius = 10.0;
        rl.DrawPoly(
            .{ .x = 200.0, .y = 0.0 },
            poly_shape_sides,
            poly_shape_radius,
            0.0,
            TRON_BLUE,
        );
        rl.DrawPoly(
            .{ .x = 0.0, .y = 200.0 },
            poly_shape_sides,
            poly_shape_radius,
            90.0,
            TRON_BLUE,
        );

        rl.DrawText("+", 205, 5, 20, TRON_BLUE);
        rl.DrawText("+", 5, 205, 20, TRON_BLUE);

        //
        // Draw world origin point to show the world's origin (0,0)
        //
        rl.DrawCircleV(.{ .x = 0.0, .y = 0.0 }, 4.0, TRON_RED);

        //
        // Draw wrold origin coordinate (0,0)
        //
        const world_pos = .{ .x = 40.0, .y = 40.0 };
        rl.DrawText(
            "World's origin (0,0)",
            @as(c_int, @intFromFloat(world_pos.x)),
            @as(c_int, @intFromFloat(world_pos.y)),
            20,
            TRON_ORANGE,
        );
        rl.DrawLineV(
            .{ .x = 3.0, .y = 3.0 },
            .{ .x = 35.0, .y = 35.0 },
            TRON_YELLOW,
        );

        rl.EndMode2D();

        rl.DrawText(
            "Mouse left button drag to move camera's target, mouse wheel to zoom",
            10,
            10,
            20,
            TRON_BLUE,
        );

        rl.DrawText(
            "Mouse wheel to zoom",
            10,
            35,
            20,
            TRON_BLUE,
        );

        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }
}
