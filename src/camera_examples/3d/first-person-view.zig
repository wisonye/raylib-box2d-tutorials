const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("rcamera.h");
});

const GAME_FPS = 60;

const TRON_DARK = rl.Color{ .r = 0x23, .g = 0x21, .b = 0x1B, .a = 0xFF };
const TRON_LIGHT_BLUE = rl.Color{ .r = 0xAC, .g = 0xE6, .b = 0xFE, .a = 0xFF };
const TRON_BLUE = rl.Color{ .r = 0x6F, .g = 0xC3, .b = 0xDF, .a = 0xFF };
const TRON_YELLOW = rl.Color{ .r = 0xFF, .g = 0xE6, .b = 0x4D, .a = 0xFF };
const TRON_ORANGE = rl.Color{ .r = 0xFF, .g = 0x9F, .b = 0x1C, .a = 0xFF };
const TRON_RED = rl.Color{ .r = 0xF4, .g = 0x47, .b = 0x47, .a = 0xFF };

const MAX_BUILDINGS = 20;

///
///
///
const Building = struct {
    height: f32,
    position: rl.Vector3,
    color: rl.Color,

    pub fn create_random_3d_buildings() [MAX_BUILDINGS]Building {
        var buildings: [MAX_BUILDINGS]Building = undefined;

        for (&buildings) |*current_building| {
            const temp_height: f32 = @floatFromInt(rl.GetRandomValue(1, 12));
            current_building.* = .{
                .height = temp_height,
                .position = .{
                    .x = @floatFromInt(rl.GetRandomValue(-15, 15)),
                    .y = temp_height / 2.0,
                    .z = @floatFromInt(rl.GetRandomValue(-15, 15)),
                },
                .color = .{
                    .r = @as(u8, @intCast(rl.GetRandomValue(100, 250))),
                    .g = @as(u8, @intCast(rl.GetRandomValue(100, 250))),
                    .b = @as(u8, @intCast(rl.GetRandomValue(100, 250))),
                    .a = 255,
                },
            };
        }

        return buildings;
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
    rl.InitWindow(screen_width, screen_height, "Camera 3D first person view");
    defer rl.CloseWindow();

    // Set refresh rate (AKA, FPS: Frame Per Second)
    rl.SetTargetFPS(GAME_FPS);

    // Set tracing log level (DEBUG/INFO/WARN/ERROR)
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    //
    // Random 3d building
    //
    const buildings = Building.create_random_3d_buildings();

    //
    // Setup camera to look into our 3d world (position, target, up vector)
    //
    var camera = rl.Camera3D{
        .position = .{ .x = 0.0, .y = 2.0, .z = 4.0 }, // Camera position
        .target = .{ .x = 0.0, .y = 2.0, .z = 0.0 }, // Camera looking at point
        .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 }, // Camera up vector (rotation towards target)
        .fovy = 60.0, // Camera field-of-view Y
        .projection = rl.CAMERA_PERSPECTIVE, // Camera projection type
    };

    var camera_mode: c_int = rl.CAMERA_FIRST_PERSON;

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
        // Switch camera mode
        //
        if (rl.IsKeyPressed(rl.KEY_ONE)) {
            camera_mode = rl.CAMERA_FREE;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 }; // Reset roll
        }

        if (rl.IsKeyPressed(rl.KEY_TWO)) {
            camera_mode = rl.CAMERA_FIRST_PERSON;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 }; // Reset roll
        }

        if (rl.IsKeyPressed(rl.KEY_THREE)) {
            camera_mode = rl.CAMERA_THIRD_PERSON;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 }; // Reset roll
        }

        if (rl.IsKeyPressed(rl.KEY_FOUR)) {
            camera_mode = rl.CAMERA_ORBITAL;
            camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 }; // Reset roll
        }
        //
        // Switch camera projection
        //
        if (rl.IsKeyPressed(rl.KEY_P)) {
            if (camera.projection == rl.CAMERA_PERSPECTIVE) {
                // Create isometric view
                camera_mode = rl.CAMERA_THIRD_PERSON;
                // Note: The target distance is related to the render distance in the orthographic projection
                camera.position = .{ .x = 0.0, .y = 2.0, .z = -100.0 };
                camera.target = .{ .x = 0.0, .y = 2.0, .z = 0.0 };
                camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
                camera.projection = rl.CAMERA_ORTHOGRAPHIC;
                camera.fovy = 20.0; // near plane width in CAMERA_ORTHOGRAPHIC
                rl.CameraYaw(&camera, -135 * rl.DEG2RAD, true);
                rl.CameraPitch(&camera, -45 * rl.DEG2RAD, true, true, false);
            } else if (camera.projection == rl.CAMERA_ORTHOGRAPHIC) {
                // Reset to default view
                camera_mode = rl.CAMERA_THIRD_PERSON;
                camera.position = .{ .x = 0.0, .y = 2.0, .z = 10.0 };
                camera.target = .{ .x = 0.0, .y = 2.0, .z = 0.0 };
                camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
                camera.projection = rl.CAMERA_PERSPECTIVE;
                camera.fovy = 60.0;
            }
        }

        // Update camera computes movement internally depending on the camera mode
        // Some default standard keyboard/mouse inputs are hardcoded to simplify use
        // For advance camera controls, it's reecommended to compute camera movement manually
        rl.UpdateCamera(&camera, camera_mode);

        // -------------------------------------------------------------
        // Redraw the entire frame
        // -------------------------------------------------------------
        rl.BeginDrawing();

        rl.ClearBackground(TRON_DARK);

        rl.BeginMode3D(camera);

        rl.DrawPlane(.{ .x = 0.0, .y = 0.0, .z = 0.0 }, .{ .x = 32.0, .y = 32.0 }, rl.LIGHTGRAY); // Draw ground
        rl.DrawCube(.{ .x = -16.0, .y = 2.5, .z = 0.0 }, 1.0, 5.0, 32.0, TRON_YELLOW); // Draw a blue wall
        rl.DrawCube(.{ .x = 16.0, .y = 2.5, .z = 0.0 }, 1.0, 5.0, 32.0, TRON_ORANGE); // Draw a green wall
        rl.DrawCube(.{ .x = 0.0, .y = 2.5, .z = 16.0 }, 32.0, 5.0, 1.0, TRON_BLUE); // Draw a yellow wall

        // Draw some cubes around
        for (buildings) |temp_building| {
            rl.DrawCube(
                temp_building.position,
                2.0,
                temp_building.height,
                2.0,
                temp_building.color,
            );
            rl.DrawCubeWires(
                temp_building.position,
                2.0,
                temp_building.height,
                2.0,
                TRON_DARK,
            );
        }

        // Draw player cube
        if (camera_mode == rl.CAMERA_THIRD_PERSON) {
            rl.DrawCube(camera.target, 0.5, 0.5, 0.5, TRON_RED);
            rl.DrawCubeWires(camera.target, 0.5, 0.5, 0.5, TRON_DARK);
        }

        rl.EndMode3D();

        // Draw info boxes
        rl.DrawRectangle(5, 5, 530, 150, rl.Fade(TRON_LIGHT_BLUE, 0.5));
        rl.DrawRectangleLines(5, 5, 530, 150, TRON_BLUE);

        rl.DrawText("Camera controls:", 20, 15, 20, TRON_DARK);
        rl.DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 20, 40, 20, TRON_DARK);
        rl.DrawText("- Look around: arrow keys or mouse", 20, 60, 20, TRON_DARK);
        rl.DrawText("- Camera mode keys: 1, 2, 3, 4", 20, 80, 20, TRON_DARK);
        rl.DrawText("- Zoom keys: num-plus, num-minus or mouse scroll", 20, 100, 20, TRON_DARK);
        rl.DrawText("- Camera projection key: P", 20, 120, 20, TRON_DARK);

        rl.DrawRectangle(600, 5, 380, 160, rl.Fade(TRON_LIGHT_BLUE, 0.5));
        rl.DrawRectangleLines(600, 5, 380, 160, TRON_BLUE);

        rl.DrawText("Camera status:", 610, 15, 20, TRON_DARK);
        rl.DrawText(
            rl.TextFormat("- Mode: %s", switch (camera_mode) {
                rl.CAMERA_FREE => @as([*c]const u8, @ptrCast("FREE")),
                rl.CAMERA_FIRST_PERSON => @as([*c]const u8, @ptrCast("FIRST_PERSON")),
                rl.CAMERA_THIRD_PERSON => @as([*c]const u8, @ptrCast("THIRD_PERSON")),
                rl.CAMERA_ORBITAL => @as([*c]const u8, @ptrCast("ORBITAL")),
                else => @as([*c]const u8, @ptrCast("CUSTOM")),
            }),
            610,
            50,
            20,
            TRON_DARK,
        );
        rl.DrawText(
            rl.TextFormat("- Projection: %s", switch (camera.projection) {
                rl.CAMERA_PERSPECTIVE => @as([*c]const u8, @ptrCast("PERSPECTIVE")),
                rl.CAMERA_ORTHOGRAPHIC => @as([*c]const u8, @ptrCast("ORTHOGRAPHIC")),
                else => @as([*c]const u8, @ptrCast("CUSTOM")),
            }),

            610,
            70,
            20,
            TRON_DARK,
        );
        rl.DrawText(
            rl.TextFormat("- Position: (%06.3f, %06.3f, %06.3f)", camera.position.x, camera.position.y, camera.position.z),
            610,
            100,
            20,
            TRON_DARK,
        );
        rl.DrawText(
            rl.TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", camera.target.x, camera.target.y, camera.target.z),
            610,
            120,
            20,
            TRON_DARK,
        );
        rl.DrawText(
            rl.TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", camera.up.x, camera.up.y, camera.up.z),
            610,
            140,
            20,
            TRON_DARK,
        );

        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }
}
