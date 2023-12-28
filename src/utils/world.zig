//!
//! Represent Box2D world
//!
const b = @cImport({
    @cInclude("box2d/box2d.h");
    @cInclude("stdio.h");
});

const rl = @cImport({
    @cInclude("raylib.h");
});

const Game = @import("./game.zig");

const World = @This();

world_id: ?b.b2WorldId,
ground_body_id: ?b.b2BodyId,
ground_body_width: f32,
ground_body_height: f32,

///
/// Create Box2D world
///
pub fn init() World {
    //
    // `b.b2DefaultWorldDef()` applies the default gravity {.x = 0.0, .y = -10.0}
    //
    var world_def: b.b2WorldDef = b.b2DefaultWorldDef();

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
) Game.GameError!void {
    if (self.world_id == null) {
        return Game.GameError.WorldNotExists;
    }

    if (self.ground_body_id) |_| {
        return Game.GameError.GroundAlreadyExists;
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
pub fn run_simulation_step(self: *const World) Game.GameError!void {
    if (self.world_id == null) {
        return Game.GameError.WorldNotExists;
    }

    if (self.world_id) |w| {
        //
        // Typically we use a time step of 1/60 of a second (60Hz) and 10 iterations. This
        // provides a high quality simulation in most game scenarios.
        //
        const simulation_time_step: f32 = 1.0 / @as(f32, @floatFromInt(Game.GAME_FPS));
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
    const world_position = b.b2Body_GetPosition(self.ground_body_id.?);
    const angle = b.b2Body_GetAngle(self.ground_body_id.?);

    // Meter to pixel
    const width = self.ground_body_width / Game.PIXEL_TO_WORLD_SCALE_FACTOR;
    const height = self.ground_body_height / Game.PIXEL_TO_WORLD_SCALE_FACTOR;

    // World coordinate to screen camera coordinate (camera's `offset/origin` on screen)
    const screen_pos = rl.Vector2{
        .x = world_position.x / Game.PIXEL_TO_WORLD_SCALE_FACTOR,
        .y = (world_position.y / Game.PIXEL_TO_WORLD_SCALE_FACTOR) * -1.0,
    };

    // rl.TraceLog(
    //     rl.LOG_DEBUG,
    //     ">>> [ Box > redraw_ground_box ] - body position - x: %.2f y: %.2f, angle: %.2f, " ++
    //         "screen position - x: %.2f y: %.2f, screen_width: %.2f, screen_height: %.2f",
    //     world_position.x,
    //     world_position.y,
    //     angle,
    //     screen_pos.x,
    //     screen_pos.y,
    //     width,
    //     height,
    // );

    const rect = rl.Rectangle{
        .x = screen_pos.x - (width / 2),
        .y = screen_pos.y - (height / 2),
        .width = width,
        .height = height,
    };
    rl.DrawRectanglePro(
        rect,
        .{ .x = 0.0, .y = 0.0 },
        angle,
        Game.Color.TRON_ORANGE,
    );

    // Draw center line
    rl.DrawLine(
        @intFromFloat(screen_pos.x - (width / 2)),
        @intFromFloat(screen_pos.y),
        @intFromFloat(screen_pos.x + (width / 2)),
        @intFromFloat(screen_pos.y),
        Game.Color.TRON_DARK,
    );

    // Draw center point: the world's origin (0,0)
    // rl.DrawCircleV(.{ .x = screen_pos.x, .y = screen_pos.y }, 4.0, Game.Color.TRON_RED);
    rl.DrawCircleV(.{ .x = 0.0, .y = 0.0 }, 2.0, Game.Color.TRON_DARK);
}
