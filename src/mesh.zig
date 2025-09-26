const Vec3 = @import("vec3.zig").Vec3;
const triangle = @import("triangle.zig");
const Face = triangle.Face;
const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error {
OBJNotFound
};

pub const Mesh = struct {
    vertices: std.ArrayList(Vec3),
    faces: std.ArrayList(Face),
    rotation: Vec3 = Vec3.zero(),

    pub fn init(allocator: Allocator) Mesh {
        return Mesh {
          .vertices = std.ArrayList(Vec3).init(allocator),
          .faces = std.ArrayList(Face).init(allocator)
        };
    }

    pub fn loadOBJ(self: *Mesh) !void {
        return;
    }
};