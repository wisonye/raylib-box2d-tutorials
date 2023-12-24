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
const Camera2D = @import("utils/camera_2d.zig");

const GAME_FPS = 60;

//
// 1 screen pixel represents how many meters in the Box2D world
//
const PIXEL_TO_WORLD_SCALE_FACTOR = 0.1;

const TRON_DARK = rl.Color{ .r = 0x23, .g = 0x21, .b = 0x1B, .a = 0xFF };
const TRON_LIGHT_BLUE = rl.Color{ .r = 0xAC, .g = 0xE6, .b = 0xFE, .a = 0xFF };
const TRON_BLUE = rl.Color{ .r = 0x6F, .g = 0xC3, .b = 0xDF, .a = 0xFF };
const TRON_YELLOW = rl.Color{ .r = 0xFF, .g = 0xE6, .b = 0x4D, .a = 0xFF };
const TRON_ORANGE = rl.Color{ .r = 0xFF, .g = 0x9F, .b = 0x1C, .a = 0xFF };
const TRON_RED = rl.Color{ .r = 0xF4, .g = 0x47, .b = 0x47, .a = 0xFF };

///
///
///
pub const GameError = error{
    WorldNotExists,
    GroundAlreadyExists,
};

///
/// Represent Box2D world
///
const World = struct {
    world_id: ?b.b2WorldId,
    ground_body_id: ?b.b2BodyId,
    ground_body_width: f32,
    ground_body_height: f32,

    ///
    /// Create Box2D world
    ///
    pub fn init() World {
        const gravity: b.b2Vec2 = .{ .x = 0.0, .y = -10.0 };
        var world_def: b.b2WorldDef = b.b2DefaultWorldDef();
        world_def.gravity = gravity;

        rl.TraceLog(rl.LOG_INFO, ">>> [ World > init ] - Box2D world created.");

        return .{
            .world_id = b.b2CreateWorld(&world_def),
            .ground_body_id = null,
            .ground_body_width = 0.0,
            .ground_body_height = 0.0,
        };
    }

    ///
    /// Create static ground box.
    ///
    /// `init_position` is Box2D world coordinate (not screen coordinate),
    /// `width` and `height` are meters.
    ///
    pub fn create_static_ground_box(
        self: *World,
        init_position: b.b2Vec2,
        width: f32,
        height: f32,
    ) GameError!void {
        if (self.world_id == null) {
            return GameError.WorldNotExists;
        }

        if (self.ground_body_id) |_| {
            return GameError.GroundAlreadyExists;
        }

        var ground_body_def = b.b2DefaultBodyDef();
        ground_body_def.position = init_position;

        self.ground_body_id = b.b2World_CreateBody(self.world_id.?, &ground_body_def);

        const ground_box = b.b2MakeBox(width / 2, height / 2);
        self.ground_body_width = width;
        self.ground_body_height = height;

        var ground_shape_def = b.b2DefaultShapeDef();
        _ = b.b2Body_CreatePolygon(self.ground_body_id.?, &ground_shape_def, &ground_box);

        rl.TraceLog(
            rl.LOG_INFO,
            ">>> [ World > create_static_ground_box ] - Box2D static ground box created.",
        );
    }

    ///
    /// Instruct the world to perform a single step of simulation.
    /// It is generally best to keep the time step and iterations fixed.
    ///
    pub fn run_simulation_step(self: *const World) GameError!void {
        if (self.world_id == null) {
            return GameError.WorldNotExists;
        }

        if (self.world_id) |w| {
            //
            // Typically we use a time step of 1/60 of a second (60Hz) and 10 iterations. This
            // provides a high quality simulation in most game scenarios.
            //
            const simulation_time_step: f32 = 1.0 / @as(f32, @floatFromInt(GAME_FPS));
            const simulation_velocity_iterations: i32 = 6;
            const simulation_relax_iterations: i32 = 2;

            b.b2World_Step(
                w,
                simulation_time_step,
                simulation_velocity_iterations,
                simulation_relax_iterations,
            );
        }
    }

    ///
    ///
    ///
    pub fn deinit(self: *World) void {
        rl.TraceLog(
            rl.LOG_INFO,
            ">>> [ World > deinit ] - Try to destroy Box2D world......",
        );

        if (self.world_id) |w| {
            //
            // When the world destructor is called, all bodies and joints are freed.
            //
            b.b2DestroyWorld(w);

            rl.TraceLog(
                rl.LOG_INFO,
                ">>> [ World > deinit ] - Box2D world destoryed.",
            );

            self.world_id = null;
            self.ground_body_id = null;
        }
    }

    ///
    ///
    ///
    pub fn redraw_ground_box(self: *const World) void {
        const position = b.b2Body_GetPosition(self.ground_body_id.?);
        const angle = b.b2Body_GetAngle(self.ground_body_id.?);

        const width = self.ground_body_width / PIXEL_TO_WORLD_SCALE_FACTOR;
        const height = self.ground_body_height / PIXEL_TO_WORLD_SCALE_FACTOR;
        const screen_vec = rl.Vector2{
            .x = position.x / PIXEL_TO_WORLD_SCALE_FACTOR + width / 2.0,
            .y = (position.y / PIXEL_TO_WORLD_SCALE_FACTOR) * -1.0 + height / 2.0,
        };

        rl.TraceLog(
            rl.LOG_DEBUG,
            ">>> [ Box > redraw_ground_box ] - body position - x: %.2f y: %.2f, angle: %.2f, " ++
                "screen position - x: %.2f y: %.2f, screen_width: %.2f, screen_height: %.2f",
            position.x,
            position.y,
            angle,
            screen_vec.x,
            screen_vec.y,
            width,
            height,
        );

        const rect = rl.Rectangle{
            .x = screen_vec.x - (width / 2),
            .y = screen_vec.y - (height / 2),
            .width = width,
            .height = height,
        };
        rl.DrawRectanglePro(
            rect,
            //
            // Rotation origin is related to the left-top position {0,0}, if you want it to
            // rotate on the centre of the rectangle, that means {width/2, height/2}.
            //
            rl.Vector2{ .x = width / 2, .y = height / 2 },
            angle,
            TRON_ORANGE,
        );
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

    camera: *const Camera2D,

    body_id: b.b2BodyId,

    ///
    /// Create dynamic box.
    ///
    /// - `init_world_position` is Box2D world coordinate (not screen coordinate),
    /// - `body_width` and `body_height` are meters.
    /// - `density` (default is 0.0): affect the mass
    /// - `friction` (default value 0.6)
    /// - `restitution` (default is 0.0): affect the bouncing behaviour, default is no boucing
    ///
    pub fn init(
        world: *const World,
        camera: *const Camera2D,
        init_world_position: b.b2Vec2,
        body_width: f32,
        body_height: f32,
        density: ?f32,
        friction: ?f32,
        restitution: ?f32,
    ) GameError!Box {
        if (world.*.world_id == null) {
            return GameError.WorldNotExists;
        }

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
        const body_id = b.b2World_CreateBody(world.*.world_id.?, &body_def);

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
            ">>> [ Box > init ] - Box2D dynamic box created, index: %d, : Dynamic body mass: %4.2f",
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
        const screen_vec = rl.Vector2{
            .x = position.x / PIXEL_TO_WORLD_SCALE_FACTOR,
            .y = (position.y / PIXEL_TO_WORLD_SCALE_FACTOR) * -1.0,
        };
        const width = self.body_width / PIXEL_TO_WORLD_SCALE_FACTOR;
        const height = self.body_height / PIXEL_TO_WORLD_SCALE_FACTOR;

        rl.TraceLog(
            rl.LOG_DEBUG,
            ">>> [ Box > redraw ] - body position - x: %.2f y: %.2f, angle: %.2f, " ++
                "screen position - x: %.2f y: %.2f, screen_width: %.2f, screen_height: %.2f",
            position.x,
            position.y,
            angle,
            screen_vec.x,
            screen_vec.y,
            width,
            height,
        );

        const rect = rl.Rectangle{
            .x = screen_vec.x - (width / 2),
            .y = screen_vec.y - (height / 2),
            .width = width,
            .height = height,
        };

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
    // rl.EnableEventWaiting();

    var camera = Camera2D.init(
        @as(usize, @intCast(rl.GetScreenWidth())),
        @as(usize, @intCast(rl.GetScreenHeight())),
    );

    rl.TraceLog(rl.LOG_INFO, ">>> Camera created");

    var world = World.init();
    try world.create_static_ground_box(.{ .x = 0.0, .y = 0.0 }, 50.0, 2.0);
    defer world.deinit();

    const dynamic_bodies = [_]Box{
        try Box.init(&world, &camera, .{ .x = 0.0, .y = 10.0 }, 1.0, 1.0, null, null, 0.7),
        try Box.init(&world, &camera, .{ .x = 2.0, .y = 20.0 }, 1.0, 1.0, null, null, 0.6),
        try Box.init(&world, &camera, .{ .x = 3.0, .y = 30.0 }, 1.0, 1.0, null, null, 0.7),
        try Box.init(&world, &camera, .{ .x = 4.0, .y = 40.0 }, 1.0, 1.0, null, null, 0.6),
    };

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
        const current_zoom = camera.get_zoom();
        camera.set_zoom(current_zoom + rl.GetMouseWheelMove() * 0.05);

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

        try world.run_simulation_step();

        //
        // Redraw everything
        //
        rl.BeginDrawing();
        rl.ClearBackground(TRON_DARK);

        rl.BeginMode2D(camera._internal_camera);

        world.redraw_ground_box();
        for (&dynamic_bodies) |*box| {
            box.*.redraw();
        }

        rl.EndMode2D();

        rl.EndDrawing();
    }
}
