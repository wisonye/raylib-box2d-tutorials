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

const GAME_FPS = 60;
// const GAME_FPS = 30;
const SCALING_FACTOR = 0.01;

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

///
///
///
fn create_world() b.b2WorldId {
    // Define the gravity vector.
    const gravity: b.b2Vec2 = .{ .x = 0.0, .y = -10.0 };

    // Construct a world object, which will hold and simulate the rigid bodies.
    var world_def: b.b2WorldDef = b.b2DefaultWorldDef();
    world_def.gravity = gravity;

    rl.TraceLog(rl.LOG_INFO, ">>> Box2D world created");

    return b.b2CreateWorld(&world_def);
}

///
/// Simulate the realworld ground box (static rigid body) in Box2D world,
/// dimension unit in meter.
///
const GroundBox = struct {
    //
    // `init_position` is Box2D world coordinate (not screen coordinate),
    // `width` and `height` are meters.
    //
    pub fn init(
        world_id: *const b.b2WorldId,
        init_position: b.b2Vec2,
        width: f32,
        height: f32,
    ) GroundBox {

        // Define the ground body.
        var ground_body_def = b.b2DefaultBodyDef();
        ground_body_def.position = init_position;

        // Call the body factory which allocates memory for the ground body
        // from a pool and creates the ground box shape (also from a pool).
        // The body is also added to the world.
        const ground_body_id = b.b2World_CreateBody(world_id.*, &ground_body_def);

        // Define the ground box shape. The extents are the half-widths of the box.
        const ground_box = b.b2MakeBox(width / 2, height / 2);

        // Add the box shape to the ground body.
        var ground_shape_def = b.b2DefaultShapeDef();
        _ = b.b2Body_CreatePolygon(ground_body_id, &ground_shape_def, &ground_box);

        rl.TraceLog(rl.LOG_INFO, ">>> Box2D ground box created");

        return .{};
    }
};

///
/// Simulate the realworld box in Box2D world
///
const Box = struct {

    //
    // Dimension unit in meter
    //
    body_width: f32,
    body_height: f32,

    // //
    // // Screen demesion unit is pixel
    // //
    // screen_width: f32,
    // screen_height: f32,

    camera: *const Camera,

    body_id: b.b2BodyId,

    ///
    ///
    ///
    pub fn init(
        world_id: *const b.b2WorldId,
        camera: *const Camera,
        init_world_position: b.b2Vec2,
        body_width: f32,
        body_height: f32,
        density: ?f32,
        friction: ?f32,
        restitution: ?f32,
    ) Box {

        // 1. Create `BodyDef` with the following attributes:
        // - init position
        // - type
        //     > static (default): zero mass, zero velocity, may be manually moved
        //     > kinematic: zero mass, non-zero velocity set by user, moved by solver
        //     > dynamic: positive mass, non-zero velocity determined by forces, moved by
        //       solver
        var body_def = b.b2DefaultBodyDef();
        body_def.type = b.b2_dynamicBody;
        body_def.position = init_world_position;

        //
        // 2. Create the `Body` by the given `BodyDef` (heap-allocated), `Body` has no geometry
        // (no shape), it represents the physical attributes: position, velocity, acceleration,
        // force, torque, mass, etc.
        //
        const body_id = b.b2World_CreateBody(world_id.*, &body_def);

        // Set mass
        // b.b2Body_SetMassData(body_id, massData: b2MassData)

        //
        // 3. Create `Shape` (heap-allocated) and attach it to the `Body`, it determines how the
        // `Body` looks like:
        //     > `b2MakeBox/b2MakeRoundedBox` -> Polygon Shape - Including Box/Rectangle/Square
        //       (4 vertices polygon)
        //     > `b2Circle` -> Circle Shape
        //     > `b2MakeCapsule` -> Capsule Shape
        //     > Chain Shape - used as surface
        //
        //    You need to create `b2ShapeDef` to describe the other physical attributes, e.g:
        //     - friction (default value 0.6)
        //     - restitution (default is 0.0): affect the bouncing behaviour
        //     - density (default is 0.0): affect the mass
        //
        const dynamic_box = b.b2MakeBox(body_width / 2, body_height / 2);

        var shape_def = b.b2DefaultShapeDef();

        shape_def.density = density orelse 1.0;

        if (friction) |value| {
            shape_def.friction = value;
        }

        if (restitution) |value| {
            shape_def.restitution = value;
        }

        //
        // Attach the shape to the body.
        //
        // b2Body_CreateCircle(b2BodyId bodyId, const b2ShapeDef* def, const b2Circle* circle);
        // b2Body_CreateSegment(b2BodyId bodyId, const b2ShapeDef* def, const b2Segment* segment);
        // b2Body_CreateCapsule(b2BodyId bodyId, const b2ShapeDef* def, const b2Capsule* capsule);
        // b2Body_CreatePolygon(b2BodyId bodyId, const b2ShapeDef* def, const b2Polygon* polygon);
        // b2Body_CreateChain(b2BodyId bodyId, const b2ChainDef* def);
        //
        _ = b.b2Body_CreatePolygon(body_id, &shape_def, &dynamic_box);

        rl.TraceLog(
            rl.LOG_INFO,
            ">>> Box2D dynamic box created, index: %d, : Dynamic body mass: %4.2f",
            body_id.index,
            b.b2Body_GetMass(body_id),
        );

        return .{
            .body_id = body_id,
            .body_width = body_width,
            .body_height = body_height,
            .camera = camera,
        };
    }

    ///
    ///
    ///
    pub fn redraw(self: *const Box) void {
        const position = b.b2Body_GetPosition(self.body_id);
        const angle = b.b2Body_GetAngle(self.body_id);
        const screen_vec = self.camera.convert_world_to_screen(position);

        const width = self.body_width / SCALING_FACTOR;
        const height = self.body_height / SCALING_FACTOR;
        // const screen_radius = self.body_width / SCALING_FACTOR / 2.0;

        print("\n>>> [ Box > redraw ] - body position - x: {d:.2} y: {d:.2}, angle: {d:.2}, " ++
            "screen position - x: {d:.2} y: {d:.2}, screen_width: {d:.2}, screen_height: {d:.2}", .{
            position.x,
            position.y,
            angle,
            screen_vec.x,
            screen_vec.y,
            width,
            height,
        });

        // rl.DrawCircleV(
        //     rl.Vector2{ .x = screen_vec.x, .y = screen_vec.y },
        //     screen_radius,
        //     TRON_RED,
        // );

        const rect = rl.Rectangle{
            .x = screen_vec.x - (width / 2),
            .y = screen_vec.y - (height / 2),
            .width = width,
            .height = height,
        };
        // rl.DrawRectangle(
        //     @intFromFloat(rect.x),
        //     @intFromFloat(rect.y),
        //     @intFromFloat(rect.width),
        //     @intFromFloat(rect.height),
        //     TRON_ORANGE,
        // );
        // rl.DrawRectangleV(
        //     rl.Vector2{ .x = rect.x, .y = rect.y },
        //     rl.Vector2{ .x = width, .y = height },
        //     TRON_YELLOW,
        // );
        rl.DrawRectanglePro(
            rect,
            //
            // Rotation origin is related to the left-top position {0,0}, if you want it to
            // rotate on the centre of the rectangle, that means {width/2, height/2}.
            //
            rl.Vector2{ .x = width / 2, .y = height / 2 },
            angle,
            TRON_RED,
        );
    }
};

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

    var camera = Camera.init(
        @as(usize, @intCast(rl.GetScreenWidth())),
        @as(usize, @intCast(rl.GetScreenHeight())),
    );
    // camera.zoom = 2.0;
    rl.TraceLog(rl.LOG_INFO, ">>> Camera created");

    const world_id = create_world();
    // When the world destructor is called, all bodies and joints are freed. This can
    // create orphaned ids, so be careful about your world management.
    defer b.b2DestroyWorld(world_id);

    _ = GroundBox.init(&world_id, .{ .x = 0.0, .y = -5.0 }, 50.0, 5.0);

    const dynamic_bodies = [_]Box{
        Box.init(&world_id, &camera, .{ .x = 0.0, .y = 40.0 }, 0.5, 0.5, null, null, 0.7),
        Box.init(&world_id, &camera, .{ .x = 0.5, .y = 30.0 }, 0.5, 0.5, null, null, 0.6),
    };

    //
    // Prepare for simulation. Typically we use a time step of 1/60 of a
    // second (60Hz) and 10 iterations. This provides a high quality simulation
    // in most game scenarios.
    //
    const simulation_time_step: f32 = 1.0 / @as(f32, @floatFromInt(GAME_FPS));
    const simulation_velocity_iterations: i32 = 6;
    const simulation_relax_iterations: i32 = 2;

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
                ">>> Mouse clicked at : (%d, %d)",
                mouse_pos.x,
                mouse_pos.y,
            );
        }

        //
        // Instruct the world to perform a single step of simulation.
        // It is generally best to keep the time step and iterations fixed.
        //
        b.b2World_Step(
            world_id,
            simulation_time_step,
            simulation_velocity_iterations,
            simulation_relax_iterations,
        );

        //
        // Redraw everything
        //
        rl.BeginDrawing();
        draw_demo_window(0);
        // draw_demo_window(1);
        // draw_demo_window(2);

        for (&dynamic_bodies) |*box| {
            box.*.redraw();
        }

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
