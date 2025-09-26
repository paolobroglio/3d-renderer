const color = @import("color.zig");


pub const Triangle = struct {
    v1: i32,
    v2: i32,
    v3: i32,
    color: color.Color
};

pub const Face = struct {
  a: i32,
  b: i32,
  c: i32
};