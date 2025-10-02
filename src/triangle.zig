const color = @import("color.zig");
const Vec2 = @import("vec2.zig").Vec2;

pub const Triangle = struct { v1: Vec2, v2: Vec2, v3: Vec2, color: color.Color };

pub const Face = struct { a: i32, b: i32, c: i32 };
