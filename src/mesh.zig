const Vec3 = @import("vec3.zig").Vec3;
const triangle = @import("triangle.zig");
const Face = triangle.Face;
const std = @import("std");
const fs = std.fs;
const io = std.io;
const log = std.log;
const Allocator = std.mem.Allocator;

pub const Error = error {
OBJFile
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

    pub fn loadOBJ(self: *Mesh, obj_filepath: []const u8) Error!void {
        const obj_file = fs.cwd().openFile(obj_filepath, .{}) catch |err|{
            log.err("Error when opening OBJ file {s} - {}", .{obj_filepath, err});
            return Error.OBJFile;
        };
        defer obj_file.close();

        var buf_reader = io.bufferedReader(obj_file.reader());
        var input_stream = buf_reader.reader();
        var buffer: [1024]u8 = undefined;
        while (try input_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
            if (std.mem.startsWith(u8, line, "v ")) {
                var iter = std.mem.tokenizeScalar(u8, line[2..], ' ');
                const x = try std.fmt.parseFloat(f32, iter.next().?);
                const y = try std.fmt.parseFloat(f32, iter.next().?);
                const z = try std.fmt.parseFloat(f32, iter.next().?);

                try self.vertices.append(Vec3{.x = x, .y = y, .z = z});
            }
            if (std.mem.startsWith(u8, line, "f ")) {
                var iter = std.mem.tokenizeScalar(u8, line[2..], ' ');
                var vertex_indices: [3]i32 = undefined;
                var i: usize = 0;
                while (iter.next()) |vertex_data| : (i += 1) {
                    var slash_iter = std.mem.tokenizeScalar(u8, vertex_data, '/');
                    vertex_indices[i] = try std.fmt.parseInt(i32, slash_iter.next().?, 10);
                }
                const face = Face{
                    .a = vertex_indices[0],
                    .b = vertex_indices[1],
                    .c = vertex_indices[2],
                };

                try self.faces.append(face);
            }
        }
        return;
    }
};