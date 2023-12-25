const rl = @cImport({
    @cInclude("raylib.h");
});

const std = @import("std");
const print = std.debug.print;

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
    rl.InitWindow(1024, 768, "Raylib Box2D Demo: Click to generate dynamic boxes");
    defer rl.CloseWindow();

    // Set our game FPS (frames-per-second)
    rl.SetTargetFPS(GAME_FPS);

    // Set tracing log level
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    // Hide the cursor
    // rl.HideCursor();

    // Enable waiting for events (keyboard/mouse/etc) on `EndDrawing()`,
    // no automatic event polling, save power consumsion.
    rl.EnableEventWaiting();

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
        // Press mouse button to generate new dynamic body
        //
        if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
            const mouse_pos = rl.GetMousePosition();
            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> Mouse clicked at : (%.2f, %.2f)",
                mouse_pos.x,
                mouse_pos.y,
            );
        }

        //
        // Redraw everything
        //
        rl.BeginDrawing();
        rl.ClearBackground(TRON_DARK);
        rl.EndDrawing();
    }
}
