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

const MAX_BUILDINGS = 100;

///
///
///
const Building = struct {
    rect: rl.Rectangle,
    color: rl.Color,

    pub fn create_random_buildings(player: *const PlayerBox) [MAX_BUILDINGS]Building {
        var buildings: [MAX_BUILDINGS]Building = undefined;
        var last_building_x: f32 = 0;

        for (&buildings) |*current_building| {
            // Random width between 50 ~ 200 pixels, random height between 100 ~ 800 pixels
            const random_building_width = @as(f32, @floatFromInt(rl.GetRandomValue(50, 200)));
            const random_building_height = @as(f32, @floatFromInt(rl.GetRandomValue(100, 800)));

            current_building.* = .{
                .rect = rl.Rectangle{
                    .width = random_building_width,
                    .height = random_building_height,
                    //
                    // Make the building bottom equals to player's bottom
                    //
                    .y = (player.rect.y + player.rect.height) - random_building_height,
                    .x = -2000.0 + last_building_x,
                },
                .color = .{
                    .r = @as(u8, @intCast(rl.GetRandomValue(100, 250))),
                    .g = @as(u8, @intCast(rl.GetRandomValue(100, 250))),
                    .b = @as(u8, @intCast(rl.GetRandomValue(100, 250))),
                    .a = 255,
                },
            };
            last_building_x += random_building_width;
        }

        return buildings;
    }
};

///
///
///
const PlayerBox = struct {
    rect: rl.Rectangle,
    color: rl.Color,

    pub fn init() PlayerBox {
        return .{
            .rect = .{
                .x = 400.0,
                .y = 200.0,
                .width = 50.0,
                .height = 50.0,
            },
            .color = TRON_RED,
        };
    }

    pub fn get_center_position(self: *const PlayerBox) rl.Vector2 {
        return .{
            .x = self.rect.x + self.rect.width / 2.0,
            .y = self.rect.y + self.rect.height / 2.0,
        };
    }
};

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
    rl.InitWindow(screen_width, screen_height, "Camera 2D centre with player position");
    defer rl.CloseWindow();

    // Set refresh rate (AKA, FPS: Frame Per Second)
    rl.SetTargetFPS(GAME_FPS);

    // Set tracing log level (DEBUG/INFO/WARN/ERROR)
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    //
    // Player box
    //
    var player = PlayerBox.init();

    //
    // Random building
    //
    const buildings = Building.create_random_buildings(&player);

    //
    // Setup camera
    //
    const default_camera_zoom = 0.3;
    var camera = rl.Camera2D{
        //
        // Camera/window origin in screen coordinate, set to center of the screen,
        // used for zooming and rotating
        //
        .offset = .{
            .x = @as(f32, @floatFromInt(screen_width)) / 2.0,
            .y = @as(f32, @floatFromInt(screen_height)) / 2.0,
        },
        .rotation = 0.0,
        .zoom = default_camera_zoom,
        //
        // World space point map to the camera/window origin
        //
        .target = .{
            .x = player.rect.x + player.rect.width / 2.0,
            .y = player.rect.y + player.rect.height / 2.0,
        },
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
        // Player movement
        //
        if (rl.IsKeyDown(rl.KEY_RIGHT)) {
            player.rect.x += 10.0;
        } else if (rl.IsKeyDown(rl.KEY_LEFT)) {
            player.rect.x -= 10.0;
        }

        //
        // Camera target follows player
        //
        camera.target = player.get_center_position();

        //
        // Camera rotation controls
        //
        if (rl.IsKeyDown(rl.KEY_S)) {
            camera.rotation -= 1.0;
        } else if (rl.IsKeyDown(rl.KEY_F)) {
            camera.rotation += 1.0;
        }

        //
        // Limit camera rotation to 80 degrees (-40 to 40)
        //
        if (camera.rotation > 40) {
            camera.rotation = 40.0;
        } else if (camera.rotation < -40) {
            camera.rotation = -40.0;
        }

        //
        // Camera zoom controls
        //
        camera.zoom += rl.GetMouseWheelMove() * 0.05;

        if (camera.zoom > 3.0) {
            camera.zoom = 3.0;
        } else if (camera.zoom < 0.1) {
            camera.zoom = 0.1;
        }

        //
        // Camera reset (zoom and rotation)
        //
        if (rl.IsKeyPressed(rl.KEY_R)) {
            camera.zoom = default_camera_zoom;
            camera.rotation = 0.0;
        }

        // -------------------------------------------------------------
        // Redraw the entire frame
        // -------------------------------------------------------------
        rl.BeginDrawing();

        rl.ClearBackground(TRON_DARK);

        rl.BeginMode2D(camera);

        // Draw ground, ground aligns to player's bottom
        rl.DrawRectangle(
            -6000,
            @as(c_int, @intFromFloat((player.rect.y + player.rect.height))),
            13000,
            8000,
            rl.DARKGRAY,
        );

        for (buildings) |temp_building| {
            rl.DrawRectangleRec(temp_building.rect, temp_building.color);
        }

        rl.DrawRectangleRec(player.rect, player.color);

        rl.DrawLine(
            @as(c_int, @intFromFloat(camera.target.x)),
            -screen_height * 10,
            @as(c_int, @intFromFloat(camera.target.x)),
            screen_height * 10,
            TRON_ORANGE,
        );
        rl.DrawLine(
            -screen_width * 10,
            @as(c_int, @intFromFloat(camera.target.y)),
            screen_width * 10,
            @as(c_int, @intFromFloat(camera.target.y)),
            TRON_ORANGE,
        );

        rl.EndMode2D();

        rl.DrawRectangle(10, 10, 370, 140, rl.Fade(TRON_LIGHT_BLUE, 0.5));
        rl.DrawRectangleLines(10, 10, 370, 140, TRON_BLUE);

        rl.DrawText("Free 2d camera controls:", 20, 20, 20, rl.BLACK);
        rl.DrawText("- Right/Left to move Offset", 40, 60, 20, TRON_DARK);
        rl.DrawText("- Mouse Wheel to Zoom in-out", 40, 80, 20, TRON_DARK);
        rl.DrawText("- S / F to Rotate", 40, 100, 20, TRON_DARK);
        rl.DrawText("- R to reset Zoom and Rotation", 40, 120, 20, TRON_DARK);

        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }
}
