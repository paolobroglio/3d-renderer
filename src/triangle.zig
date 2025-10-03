const color = @import("Color.zig");
const Vec2 = @import("Vec2.zig");

pub const Triangle = struct { v1: Vec2, v2: Vec2, v3: Vec2, depth: f32, color: color.Color };

pub const Face = struct { a: i32, b: i32, c: i32 };
