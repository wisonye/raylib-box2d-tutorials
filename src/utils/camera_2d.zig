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

const Camera2D = @This();

width: usize,
height: usize,
_internal_camera: rl.Camera2D,

///
///
///
pub fn init(width: usize, height: usize) Camera2D {
    return Camera2D{
        .width = width,
        .height = height,
        ._internal_camera = .{
            //
            // Box2D world's origin is at the centre (0,0), let's make the camera origin
            // to the centre of screen window, it's good for mapping world's coordinate
            // to screen coordinate.
            //
            .offset = rl.Vector2{
                .x = @as(f32, @floatFromInt(width)) / 2.0,
                .y = @as(f32, @floatFromInt(height)) / 2.0,
            },
            //
            // Box2D world's origin (0,0)
            //
            .target = rl.Vector2{ .x = 0, .y = 0 },
            .rotation = 0.0,
            .zoom = 1.0,
            // .zoom = 0.3,
        },
    };
}

///
///
///
pub fn convert_screen_to_world(self: *const Camera2D, screen_position: rl.Vector2) b.b2Vec2 {
    const world_pos = rl.GetScreenToWorld2D(screen_position, self._internal_camera);

    return .{ .x = world_pos.x, .y = world_pos.y };
}

///
///
///
pub fn convert_world_to_screen(self: *const Camera2D, world_position: b.b2Vec2) rl.Vector2 {
    const temp_pos = rl.Vector2{ .x = world_position.x, .y = world_position.y };
    const screen_pos = rl.GetWorldToScreen2D(temp_pos, self._internal_camera);

    return .{ .x = screen_pos.x, .y = screen_pos.y };
}

///
///
///
pub fn set_zoom(self: *Camera2D, new_zoom: f32) void {
    const MIN_ZOOM = 0.3;
    const MAX_ZOOM = 4.0;

    if (new_zoom > MAX_ZOOM) {
        self._internal_camera.zoom = MAX_ZOOM;
    } else if (new_zoom < MIN_ZOOM) {
        self._internal_camera.zoom = MIN_ZOOM;
    } else {
        self._internal_camera.zoom = new_zoom;
    }

    rl.TraceLog(
        rl.LOG_DEBUG,
        "[ Camera2D - set_zoom ] - zoom: %.2f",
        self._internal_camera.zoom,
    );
}

///
///
///
pub fn get_zoom(self: *const Camera2D) f32 {
    return self._internal_camera.zoom;
}

///
///
///
pub fn update_camera_target(self: *Camera2D, target_pos: rl.Vector2) void {
    self._internal_camera.target = target_pos;
}
