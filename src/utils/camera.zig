const b = @cImport({
    @cInclude("box2d/box2d.h");
    @cInclude("box2d/geometry.h");
    @cInclude("box2d/math.h");
    @cInclude("stdio.h");
});

const std = @import("std");
const print = std.debug.print;

const Camera = @This();

width: usize,
height: usize,
zoom: f32,
center: b.b2Vec2,

///
///
///
pub fn init(width: usize, height: usize) Camera {
    return Camera{
        .width = width,
        .height = height,
        .center = b.b2Vec2{ .x = 0.0, .y = 20.0 },
        .zoom = 1.0,
    };
}

///
///
///
pub fn reset_view(self: *Camera) void {
    self.center = b.b2Vec2{ .x = 0.0, .y = 20.0 };
    self.zoom = 1.0;
}

///
///
///
pub fn convert_screen_to_world(self: *const Camera, ps: b.b2Vec2) b.b2Vec2 {
    const w: f32 = @floatFromInt(self.width);
    const h: f32 = @floatFromInt(self.height);
    const u: f32 = ps.x / w;
    const v: f32 = (h - ps.y) / h;

    const ratio: f32 = w / h;
    const extents: b.b2Vec2 = .{
        .x = self.zoom * ratio * 25.0,
        .y = self.zoom * 25.0,
    };

    const lower: b.b2Vec2 = b.b2Sub(self.center, extents);
    const upper: b.b2Vec2 = b.b2Add(self.center, extents);

    return b.b2Vec2{
        .x = (1.0 - u) * lower.x + u * upper.x,
        .y = (1.0 - v) * lower.y + v * upper.y,
    };
}

///
///
///
pub fn convert_world_to_screen(self: *const Camera, pw: b.b2Vec2) b.b2Vec2 {
    const w: f32 = @floatFromInt(self.width);
    const h: f32 = @floatFromInt(self.height);
    const ratio: f32 = w / h;
    const extents: b.b2Vec2 = .{ .x = self.zoom * ratio * 25.0, .y = self.zoom * 25.0 };

    const lower: b.b2Vec2 = b.b2Sub(self.center, extents);
    const upper: b.b2Vec2 = b.b2Add(self.center, extents);

    const u: f32 = (pw.x - lower.x) / (upper.x - lower.x);
    const v: f32 = (pw.y - lower.y) / (upper.y - lower.y);

    return b.b2Vec2{ .x = u * w, .y = (1.0 - v) * h };
}
