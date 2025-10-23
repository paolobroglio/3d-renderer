const Vec3 = @import("Vec3.zig");
const triangle = @import("triangle.zig");
const Face = triangle.Face;
const std = @import("std");
const fs = std.fs;
const Io = std.Io;
const log = std.log;
const Allocator = std.mem.Allocator;

pub const Error = error{ OBJFileNotOpened, OBJFileNotFound, OBJFileMalformed, MeshOutOfMemory };

pub const Mesh = struct {
    allocator: Allocator,
    vertices: std.ArrayListUnmanaged(Vec3),
    faces: std.ArrayListUnmanaged(Face),
    rotation: Vec3 = Vec3.zero(),
    scale: Vec3 = Vec3{ .x = 1.0, .y = 1.0, .z = 1.0 },
    translation: Vec3 = Vec3.zero(),

    pub fn init(allocator: Allocator) Mesh {
        return Mesh{ .allocator = allocator, .vertices = std.ArrayListUnmanaged(Vec3).empty, .faces = std.ArrayListUnmanaged(Face).empty };
    }

    pub fn deinit(self: *Mesh) void {
        self.vertices.deinit(self.allocator);
        self.faces.deinit(self.allocator);
    }

    pub fn loadOBJ(self: *Mesh, allocator: std.mem.Allocator, obj_filepath: []const u8) Error!void {
        const obj_file = fs.cwd().openFile(obj_filepath, .{ .mode = .read_only }) catch |err| {
            log.err("Error when opening OBJ file {s} - {}", .{ obj_filepath, err });
            return Error.OBJFileNotFound;
        };
        defer obj_file.close();

        var read_buffer: [1024]u8 = undefined;
        var file_reader: std.fs.File.Reader = obj_file.reader(&read_buffer);

        const reader = &file_reader.interface;
        var line = Io.Writer.Allocating.init(allocator);
        defer line.deinit();

        while (true) {
            _ = reader.streamDelimiter(&line.writer, '\n') catch |err| {
                if (err == error.EndOfStream) break else return Error.OBJFileMalformed;
            };
            _ = reader.toss(1);

            const written_bytes = line.written();

            if (std.mem.startsWith(u8, written_bytes, "v ")) {
                var iter = std.mem.tokenizeScalar(u8, written_bytes[2..], ' ');
                const x = try parseVertexFloat(iter.next().?);
                const y = try parseVertexFloat(iter.next().?);
                const z = try parseVertexFloat(iter.next().?);

                self.vertices.append(self.allocator, Vec3{ .x = x, .y = y, .z = z }) catch |err| {
                    std.log.err("[Renderer] Vertices buffer OOM: {}", .{err});
                    return Error.MeshOutOfMemory;
                };
            }
            if (std.mem.startsWith(u8, written_bytes, "f ")) {
                var iter = std.mem.tokenizeScalar(u8, written_bytes[2..], ' ');
                var vertex_indices: [3]i32 = undefined;
                var i: usize = 0;
                while (iter.next()) |vertex_data| : (i += 1) {
                    var slash_iter = std.mem.tokenizeScalar(u8, vertex_data, '/');
                    vertex_indices[i] = std.fmt.parseInt(i32, slash_iter.next().?, 10) catch |err| {
                        std.log.err("[Renderer] Invalid int value in OBJ File: {}", .{err});
                        return Error.MeshOutOfMemory;
                    };
                }
                const face = Face{
                    .a = vertex_indices[0],
                    .b = vertex_indices[1],
                    .c = vertex_indices[2],
                };

                self.faces.append(self.allocator, face) catch |err| {
                    std.log.err("[Renderer] Faces buffer OOM: {}", .{err});
                    return Error.MeshOutOfMemory;
                };
            }

            line.clearRetainingCapacity();
        }

        return;
    }

    fn parseVertexFloat(s: []const u8) Error!f32 {
        return std.fmt.parseFloat(f32, s) catch |err| {
            std.log.err("[Renderer] Invalid float value in OBJ file: {}", .{err});
            return Error.OBJFileMalformed;
        };
    }
};
