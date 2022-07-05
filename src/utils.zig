const rl = @import("raylib/raylib.zig");

pub fn clamp(val: f16, lower: f16, higher: f16) f16 {
    if (val < lower) { return lower; }
    else if (val > higher) { return higher; }
    else { return val; }
}


pub fn f32_rand(min: f32, max: f32) f32 {
    return @intToFloat(f32, rl.GetRandomValue(@floatToInt(i32, min), @floatToInt(i32, max)));
}