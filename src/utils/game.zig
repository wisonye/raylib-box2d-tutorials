const rl = @cImport({
    @cInclude("raylib.h");
});

///
///
///
pub const GameError = error{
    WorldNotExists,
    GroundAlreadyExists,
};

///
pub const GAME_FPS = 60;

//
// 1 screen pixel represents how many meters in the Box2D world
//
pub const PIXEL_TO_WORLD_SCALE_FACTOR = 0.1;

///
///
///
pub const Color = struct {
    pub const TRON_DARK = rl.Color{ .r = 0x23, .g = 0x21, .b = 0x1B, .a = 0xFF };
    pub const TRON_LIGHT_BLUE = rl.Color{ .r = 0xAC, .g = 0xE6, .b = 0xFE, .a = 0xFF };
    pub const TRON_BLUE = rl.Color{ .r = 0x6F, .g = 0xC3, .b = 0xDF, .a = 0xFF };
    pub const TRON_YELLOW = rl.Color{ .r = 0xFF, .g = 0xE6, .b = 0x4D, .a = 0xFF };
    pub const TRON_ORANGE = rl.Color{ .r = 0xFF, .g = 0x9F, .b = 0x1C, .a = 0xFF };
    pub const TRON_RED = rl.Color{ .r = 0xF4, .g = 0x47, .b = 0x47, .a = 0xFF };
};

///
///
///
pub fn init(
    window_width: c_int,
    window_height: c_int,
    comptime window_title: []const u8,
) void {
    //
    // Enable `multisample anti-aliasing (MSAA)` to get better smoother edge rendering
    //
    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT);

    //
    // Create game window
    //
    rl.InitWindow(
        window_width,
        window_height,
        @as([*]const u8, @ptrCast(window_title)),
    );

    //
    // Set our game FPS (frames-per-second)
    //
    rl.SetTargetFPS(GAME_FPS);

    //
    // Set tracing log level
    //
    rl.SetTraceLogLevel(rl.LOG_DEBUG);
    // rl.SetTraceLogLevel(rl.LOG_INFO);

    //
    // Hide the cursor
    //
    // rl.HideCursor();

    //
    // Enable waiting for events (keyboard/mouse/etc) on `EndDrawing()`,
    // no automatic event polling, save power consumsion.
    //
    // rl.EnableEventWaiting();
}

///
///
///
pub fn deinit() void {
    rl.CloseWindow();
}
