const Vec3 = @import("Vec3.zig");

x: f32,
y: f32,
z: f32,
w: f32,

const Vec4 = @This();

pub fn fromVec3(vec3: Vec3) Vec4 {
    return Vec4 {
      .x = vec3.x,
        .y = vec3.y,
        .z = vec3.z,
        .w = 1.0
    };
}

pub fn toVec3(self: *const Vec4) Vec3 {
    return Vec3 {
        .x = self.x,
        .y = self.y,
        .z = self.z
    };
}
