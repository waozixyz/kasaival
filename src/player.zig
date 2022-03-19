const std = @import("std");
const rl = @import("raylib");


const lyra = @import("lyra.zig");

const flame = @import("particles/flame.zig");

const print = std.debug.print;
const math = std.math;

fn get_angle(diff: rl.Vector2) rl.Vector2 {
    var angle: f32 = math.atan2(f32, diff.x, diff.y);
    if (angle < 0) {
        angle += math.pi * 2.0;
    }
    return rl.Vector2{.x = math.sin(angle), .y = math.cos(angle)};
}

fn get_direction(x: f32, y: f32 ) rl.Vector2 {
    var dir = rl.Vector2{.x = 0.0, .y = 0.0};
    for (lyra.key_right) |key, i| { _ = i; if (rl.IsKeyDown(key)) { dir.x = 1; } }
    for (lyra.key_left) |key, i| { _ = i; if (rl.IsKeyDown(key)) { dir.x = -1; } }
    for (lyra.key_up) |key, i| { _ = i; if (rl.IsKeyDown(key)) { dir.y = -1; } }
    for (lyra.key_down) |key, i| { _ = i; if (rl.IsKeyDown(key)) { dir.y = 1; } }
    if (dir.y == 0 and dir.x == 0) {
        // check mouse press
        if (rl.IsMouseButtonDown(rl.MouseButton.MOUSE_LEFT_BUTTON)) {
            var diff = rl.Vector2{.x = lyra.mouse_x - x + lyra.cx, .y = lyra.mouse_y - y};
            const offset = 5;
            if (@fabs(diff.x) > offset or @fabs(diff.y) > offset) {
                dir = get_angle(diff);
            }
        }
    }
    return dir;
}
pub const Player = struct{
    flame: flame.Flame,
    position: rl.Vector2,
    hp: f16,
    xp: f16,
    speed: f16,
    pub fn load(_: *Player) void {
    }
    pub fn update(self: *Player) void {
        const x = self.position.x;
        const y = self.position.y;
        self.flame.update(x, y);
        var dir = get_direction(x, y);
        var dx = dir.x * self.speed;
        var dy = dir.y * self.speed;
        var eye_bound = lyra.game_width / 5;
        if ((x + dx < lyra.start_x + lyra.cx + eye_bound and lyra.cx > lyra.start_x )
        or (x + dx > lyra.start_x + lyra.cx + lyra.screen_width - eye_bound and lyra.cx < lyra.game_width  + lyra.start_x - lyra.screen_width)) {
            lyra.cx += dx;
        }

        if (x + dx < lyra.start_x + lyra.cx and dx < 0) {
            self.position.x = lyra.start_x + lyra.cx;
        }
        else if (x + dx > lyra.start_x + lyra.cx + lyra.screen_width) {
            self.position.x = lyra.start_x + lyra.cx + lyra.screen_width;
        }
        else {
            self.position.x += dx;
        }

        if (y + dy > lyra.screen_height and dy > 0) {
            self.position.y = lyra.screen_height;
        }
        else if (y + dy < lyra.start_y and dy < 0) {
            self.position.y = lyra.start_y;
        }
        else {
            self.position.y += dy;
        }
    }
    pub fn draw(self: *Player) void {
        self.flame.draw();
    }
    pub fn unload(self: *Player) void {
        self.flame.unload();
    }

};


pub fn new() Player {
    return Player{
        .hp = 100,
        .xp = 100,
        .speed = 20,
        .position = rl.Vector2{.x = 1920 * 0.5, .y = 1080 * 0.5},
        .flame = flame.new()};
}