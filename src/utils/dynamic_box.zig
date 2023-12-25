//!
//! Simulate the realworld box in Box2D world
//!
const b = @cImport({
    @cInclude("box2d/box2d.h");
    @cInclude("stdio.h");
});

const rl = @cImport({
    @cInclude("raylib.h");
});

const Game = @import("./game.zig");
const Camera2D = @import("./camera_2d.zig");
const World = @import("./world.zig");

const DynamicBox = @This();

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
) Game.GameError!DynamicBox {
    if (world.*.world_id == null) {
        return Game.GameError.WorldNotExists;
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
        ">>> [ DynamicBox > init ] - Box2D dynamic box created, index: %d, : Dynamic body mass: %4.2f",
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
pub fn redraw(self: *const DynamicBox) void {
    const position = b.b2Body_GetPosition(self.body_id);
    const angle = b.b2Body_GetAngle(self.body_id);
    const screen_vec = rl.Vector2{
        .x = position.x / Game.PIXEL_TO_WORLD_SCALE_FACTOR,
        .y = (position.y / Game.PIXEL_TO_WORLD_SCALE_FACTOR) * -1.0,
    };
    const width = self.body_width / Game.PIXEL_TO_WORLD_SCALE_FACTOR;
    const height = self.body_height / Game.PIXEL_TO_WORLD_SCALE_FACTOR;

    // rl.TraceLog(
    //     rl.LOG_DEBUG,
    //     ">>> [ Box > redraw ] - body position - x: %.2f y: %.2f, angle: %.2f, " ++
    //         "screen position - x: %.2f y: %.2f, screen_width: %.2f, screen_height: %.2f",
    //     position.x,
    //     position.y,
    //     angle,
    //     screen_vec.x,
    //     screen_vec.y,
    //     width,
    //     height,
    // );

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
        Game.Color.TRON_RED,
    );
}
