const rl = @import("raylib/raylib.zig");

pub fn clamp(val: f32, lower: f32, higher: f32) f32 {
    if (val < lower) {
        return lower;
    } else if (val > higher) {
        return higher;
    } else {
        return val;
    }
}

pub fn f32_rand(min: f32, max: f32) f32 {
    return @intToFloat(f32, rl.GetRandomValue(@floatToInt(i32, min), @floatToInt(i32, max)));
}

pub fn u8_rand(min: i32, max: i32) u8 {
    var val = rl.GetRandomValue(min, max);
    if (val > 255) {
        val = 255;
    }
    return @intCast(u8, val);
}
