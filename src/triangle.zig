const color = @import("Color.zig");
const Vec2 = @import("Vec2.zig");
const texture = @import("texture.zig");
const UVCoords = texture.UVCoords;

pub const Triangle = struct { v1: Vec2, v2: Vec2, v3: Vec2, v1_uv: UVCoords, v2_uv: UVCoords, v3_uv: UVCoords, depth: f32, color: color.Color };

pub const Face = struct { a: i32, b: i32, c: i32, a_uv: UVCoords, b_uv: UVCoords, c_uv: UVCoords };
