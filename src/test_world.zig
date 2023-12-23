const b = @cImport({
    @cInclude("box2d/box2d.h");
    @cInclude("box2d/geometry.h");
    @cInclude("box2d/math.h");
    @cInclude("stdio.h");
});

const rl = @cImport({
    @cInclude("raylib.h");
});

const std = @import("std");
const print = std.debug.print;
const Camera = @import("utils/camera.zig");

// const GAME_FPS = 60;
const GAME_FPS = 30;

const TRON_DARK = rl.Color{ .r = 0x23, .g = 0x21, .b = 0x1B, .a = 0xFF };
const TRON_LIGHT_BLUE = rl.Color{ .r = 0xAC, .g = 0xE6, .b = 0xFE, .a = 0xFF };
const TRON_BLUE = rl.Color{ .r = 0x6F, .g = 0xC3, .b = 0xDF, .a = 0xFF };
const TRON_YELLOW = rl.Color{ .r = 0xFF, .g = 0xE6, .b = 0x4D, .a = 0xFF };
const TRON_ORANGE = rl.Color{ .r = 0xFF, .g = 0x9F, .b = 0x1C, .a = 0xFF };
const TRON_RED = rl.Color{ .r = 0xF4, .g = 0x47, .b = 0x47, .a = 0xFF };

///
///
///
fn draw_demo_window(draw_style: u8) void {
    const demo_text = "Welcome to Raylib :)";
    var background_color = TRON_ORANGE;
    var text_color = TRON_LIGHT_BLUE;

    switch (draw_style) {
        1 => {
            background_color = TRON_ORANGE;
            text_color = TRON_DARK;
        },
        2 => {
            background_color = TRON_YELLOW;
            text_color = TRON_DARK;
        },
        else => {
            background_color = TRON_DARK;
            text_color = TRON_LIGHT_BLUE;
        },
    }

    rl.ClearBackground(background_color);
    rl.DrawText(
        demo_text,
        190,
        200,
        20,
        text_color,
    );
}

// This is a simple example of building and running a simulation
// using Box2D. Here we create a large ground box and a small dynamic
// box.
// There are no graphics for this example. Box2D is meant to be used
// with your rendering engine in your game engine.
pub fn main() !void {
    rl.InitWindow(1024, 768, "raylib [core] example - basic window");
    defer rl.CloseWindow();

    // Set our game FPS (frames-per-second)
    rl.SetTargetFPS(GAME_FPS);

    // Set tracing log level
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    // Hide the cursor
    rl.HideCursor();

    // Enable waiting for events (keyboard/mouse/etc) on `EndDrawing()`,
    // no automatic event polling, save power consumsion.
    // rl.EnableEventWaiting();

    var is_running = true;

    rl.TraceLog(rl.LOG_INFO, ">>> Ready to run");

    // Define the gravity vector.
    const gravity: b.b2Vec2 = .{ .x = 0.0, .y = -10.0 };

    // Construct a world object, which will hold and simulate the rigid bodies.
    var worldDef: b.b2WorldDef = b.b2DefaultWorldDef();
    worldDef.gravity = gravity;

    const worldId: b.b2WorldId = b.b2CreateWorld(&worldDef);

    // When the world destructor is called, all bodies and joints are freed. This can
    // create orphaned ids, so be careful about your world management.
    defer b.b2DestroyWorld(worldId);

    // Define the ground body.
    var groundBodyDef: b.b2BodyDef = b.b2DefaultBodyDef();
    // groundBodyDef.position = (b.b2Vec2){ .x = 0.0, .y = -10.0};
    groundBodyDef.position = .{ .x = 0.0, .y = -10.0 };

    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    const groundBodyId: b.b2BodyId = b.b2World_CreateBody(worldId, &groundBodyDef);

    // Define the ground box shape. The extents are the half-widths of the box.
    const groundBox: b.b2Polygon = b.b2MakeBox(50.0, 10.0);

    // Add the box shape to the ground body.
    var groundShapeDef: b.b2ShapeDef = b.b2DefaultShapeDef();
    _ = b.b2Body_CreatePolygon(groundBodyId, &groundShapeDef, &groundBox);

    // Define the dynamic body. We set its position and call the body factory.
    var bodyDef: b.b2BodyDef = b.b2DefaultBodyDef();
    bodyDef.type = b.b2_dynamicBody;
    bodyDef.position = .{ .x = 0.0, .y = 40.0 };
    const bodyId: b.b2BodyId = b.b2World_CreateBody(worldId, &bodyDef);

    // Define another box shape for our dynamic body.
    const dynamicBox: b.b2Polygon = b.b2MakeBox(1.0, 1.0);

    // Define the dynamic body shape
    var shapeDef: b.b2ShapeDef = b.b2DefaultShapeDef();

    // Set the box density to be non-zero, so it will be dynamic.
    shapeDef.density = 1.0;

    // Override the default friction.
    shapeDef.friction = 0.3;

    // Add the shape to the body.
    _ = b.b2Body_CreatePolygon(bodyId, &shapeDef, &dynamicBox);

    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    const timeStep: f32 = 1.0 / @as(f32, @floatFromInt(GAME_FPS));
    const velocityIterations: i32 = 6;
    const relaxIterations: i32 = 2;

    var position: b.b2Vec2 = b.b2Body_GetPosition(bodyId);
    var angle: f32 = b.b2Body_GetAngle(bodyId);

    rl.TraceLog(rl.LOG_INFO, ">>> Box2D world created");

    var camera = Camera.init(
        @as(usize, @intCast(rl.GetScreenWidth())),
        @as(usize, @intCast(rl.GetScreenHeight())),
    );
    camera.zoom = 2.0;
    rl.TraceLog(rl.LOG_INFO, ">>> Camera created");

    while (is_running) {
        // rl.TraceLog(rl.LOG_INFO, ">>> Redraw .....");

        if (rl.IsKeyPressed(rl.KEY_Q)) {
            is_running = false;
            rl.TraceLog(rl.LOG_INFO, ">>> Press 'Q' to exit");
        }

        if (rl.IsWindowResized()) {
            rl.TraceLog(
                rl.LOG_DEBUG,
                ">>> New width: %d, new height: %d",
                rl.GetScreenWidth(),
                rl.GetScreenHeight(),
            );
        }

        // Instruct the world to perform a single step of simulation.
        // It is generally best to keep the time step and iterations fixed.
        b.b2World_Step(worldId, timeStep, velocityIterations, relaxIterations);

        // Now print the position and angle of the body.
        position = b.b2Body_GetPosition(bodyId);
        angle = b.b2Body_GetAngle(bodyId);

        print("\n>>> Dynamic body position - x: {d:.2} y: {d:.2}, angle: {d:.2}", .{
            position.x,
            position.y,
            angle,
        });

        rl.BeginDrawing();
        draw_demo_window(0);
        // draw_demo_window(1);
        // draw_demo_window(2);

        const screen_vec = camera.convert_world_to_screen(position);
        rl.DrawCircleV(
            rl.Vector2{ .x = screen_vec.x, .y = screen_vec.y },
            10.0,
            TRON_RED,
        );

        rl.EndDrawing();
    }
}

// int EmptyWorld(void)
// {
// 	b2WorldDef worldDef = b2DefaultWorldDef();
// 	b2WorldId worldId = b2CreateWorld(&worldDef);
// 	ENSURE(b2World_IsValid(worldId) == true);

// 	float timeStep = 1.0f / 60.0f;
// 	int32_t velocityIterations = 6;
// 	int32_t relaxIterations = 2;

// 	for (int32_t i = 0; i < 60; ++i)
// 	{
// 		b2World_Step(worldId, timeStep, velocityIterations, relaxIterations);
// 	}

// 	b2DestroyWorld(worldId);

// 	ENSURE(b2World_IsValid(worldId) == false);

// 	return 0;
// }
