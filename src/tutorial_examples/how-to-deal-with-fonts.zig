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
    rl.InitWindow(1024, 768, "How to deal with fonts");
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
    // Load custom fonts
    //
    const my_font_1 = rl.LoadFont("resources/SauceCodeProNerdFont-Medium.ttf");
    const my_font_2 = rl.LoadFont("resources/anonymous_pro_bold.ttf");
    const my_font_3 = rl.LoadFont("resources/pixantiqua.ttf");
    defer rl.UnloadFont(my_font_1);
    defer rl.UnloadFont(my_font_2);
    defer rl.UnloadFont(my_font_3);

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

        // -------------------------------------------------------------
        // Redraw the entire frame
        // -------------------------------------------------------------
        rl.BeginDrawing();

        // Clear background
        rl.ClearBackground(TRON_DARK);

        const font_size = 20;
        const font_vertial_space = 5;
        const font_horizontal_space = 2.0;
        const font_pos_x: f32 = 20.0;
        var font_pos_y: f32 = 20.0;
        const msg = "This is the default font.";

        //
        // Draw with default font
        //
        rl.DrawText(
            msg,
            @intFromFloat(font_pos_x),
            @intFromFloat(font_pos_y),
            font_size,
            TRON_LIGHT_BLUE,
        );

        font_pos_y += font_size + font_vertial_space;

        rl.DrawTextEx(
            rl.GetFontDefault(),
            msg,
            .{
                .x = font_pos_x,
                .y = font_pos_y,
            },
            font_size,
            font_horizontal_space,
            TRON_LIGHT_BLUE,
        );

        //
        // Draw with custom font
        //
        const custom_font_scale = 1.5;
        var custom_font_size: f32 = @as(f32, @floatFromInt(my_font_1.baseSize)) * custom_font_scale;
        const custom_font_spacing = 2.0;
        var drawing_font_size = rl.MeasureTextEx(
            my_font_1,
            msg,
            custom_font_size,
            custom_font_spacing,
        );
        font_pos_y += font_size + font_vertial_space;
        rl.DrawTextEx(
            my_font_1,
            msg,
            .{
                .x = font_pos_x,
                .y = font_pos_y,
            },
            custom_font_size,
            custom_font_spacing,
            TRON_ORANGE,
        );

        font_pos_y += drawing_font_size.y + font_vertial_space;
        custom_font_size = @as(f32, @floatFromInt(my_font_2.baseSize)) * custom_font_scale;
        drawing_font_size = rl.MeasureTextEx(
            my_font_2,
            msg,
            custom_font_size,
            custom_font_spacing,
        );
        rl.DrawTextEx(
            my_font_2,
            msg,
            .{
                .x = font_pos_x,
                .y = font_pos_y,
            },
            custom_font_size,
            custom_font_spacing,
            TRON_ORANGE,
        );

        font_pos_y += drawing_font_size.y + font_vertial_space;
        custom_font_size = @as(f32, @floatFromInt(my_font_3.baseSize)) * custom_font_scale;
        drawing_font_size = rl.MeasureTextEx(
            my_font_3,
            msg,
            custom_font_size,
            custom_font_spacing,
        );
        rl.DrawTextEx(
            my_font_3,
            msg,
            .{
                .x = font_pos_x,
                .y = font_pos_y,
            },
            custom_font_size,
            custom_font_spacing,
            TRON_ORANGE,
        );

        rl.EndDrawing();
    }
}
