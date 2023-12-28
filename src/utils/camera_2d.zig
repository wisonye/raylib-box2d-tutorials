//!
//! Encapsulate `rl.Camera2D` and add useful functionalities
//!
const rl = @cImport({
    @cInclude("raylib.h");
});

const std = @import("std");
const print = std.debug.print;

const Camera2D = @This();

width: usize,
height: usize,
pixel_to_world_unit_scale_factor: f32,
_internal_camera: rl.Camera2D,

///
///
/// pixel_to_world_unit_scale_factor -  how many world units are represented by 1 screen pixel
///
pub fn init(
    screen_width: usize,
    screen_height: usize,
    pixel_to_world_unit_scale_factor: f32,
) Camera2D {
    return Camera2D{
        .width = screen_width,
        .height = screen_height,
        .pixel_to_world_unit_scale_factor = pixel_to_world_unit_scale_factor,
        ._internal_camera = .{
            //
            // Set the camera origin to the centre of the screen window, that camera origin point
            // represents the world's origin (0,0).
            //
            .offset = rl.Vector2{
                .x = @as(f32, @floatFromInt(screen_width)) / 2.0,
                .y = @as(f32, @floatFromInt(screen_height)) / 2.0,
            },
            //
            // `target` means the world's coordinate to show in the screen, set it to world's
            // origin (0,0) as init value. This target is always shown in the centre of the
            // camera (the centre of the screen window).
            //
            .target = rl.Vector2{ .x = 0, .y = 0 },
            .rotation = 0.0,
            .zoom = 1.0,
        },
    };
}

///
///
///
pub fn screen_to_world_pos(self: *const Camera2D, screen_position: rl.Vector2) rl.Vector2 {
    var world_pos = rl.GetScreenToWorld2D(screen_position, self._internal_camera);

    world_pos.x = world_pos.x * self.pixel_to_world_unit_scale_factor;

    // Y axis is always flipped
    world_pos.y = world_pos.y * self.pixel_to_world_unit_scale_factor * -1.0;

    return world_pos;
}

///
/// World coordinate to screen camera coordinate (camera's `offset/origin` on screen)
///
pub fn world_to_screen_pos(self: *const Camera2D, world_position: rl.Vector2) rl.Vector2 {
    //
    // Because we've already set the camera origin to the centre of the screen window, that
    // camera origin point represents the world's origin (0,0) and it has the same positive
    // direction like below:
    //
    //            |
    //            |
    //            |
    //            |
    //  ----------+----------> +
    //            |(0,0)
    //            |
    //            |
    //            |
    //            |
    //            v
    //
    //            +
    //
    // That means the camera has the same coordinate with the world!!!
    //
    return .{
        .x = world_position.x / self.pixel_to_world_unit_scale_factor,

        // Y axis is always flipped
        .y = (world_position.y / self.pixel_to_world_unit_scale_factor) * -1.0,
    };
}

///
///
///
pub fn set_zoom(self: *Camera2D, new_zoom: f32) void {
    const MIN_ZOOM = 0.1;
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
