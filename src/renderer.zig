const std = @import("std");
const log = std.log;
const rl = @import("raylib");
const Color = @import("Color.zig").Color;
const ColorBuffer = @import("colorbuffer.zig").ColorBuffer;
const mesh = @import("mesh.zig");
const Mesh = mesh.Mesh;
const Face = mesh.Face;
const Triangle = @import("triangle.zig").Triangle;
const Vec3 = @import("Vec3.zig");
const Vec2 = @import("Vec2.zig");

const WINDOW_WIDTH: u32 = 800;
const WINDOW_HEIGHT: u32 = 600;
const FPS: u32 = 60;
const FOV_FACTOR: f32 = 640.0;

pub const Error = error{ Initialization, Running, ColorBufferTextureLoadingFailed, MeshLoadingFailed, ColorBufferMemoryLeaked, TrianglesArrayOutOfMemory, Render, Projection };

const RenderMode = packed struct {
    wireframe: bool = false,
    vertices: bool = false,
    filled_faces: bool = false,
    backface_culling: bool = false,

    pub fn toggle(self: *RenderMode, flag: RenderMode) void {
        const self_int_coded: u4 = @as(u4, @bitCast(self.*));
        const flag_int_coded: u4 = @as(u4, @bitCast(flag));

        self.* = @bitCast(self_int_coded ^ flag_int_coded);
    }
};

pub const Renderer = struct {
    allocator: std.mem.Allocator,
    render_mode: RenderMode,
    camera_position: Vec3,
    is_running: bool,
    prev_frame_time: u32,

    triangles_to_render: std.ArrayListUnmanaged(Triangle),
    mesh: Mesh,
    color_buffer: ColorBuffer,
    color_buffer_texture: rl.Texture2D,

    pub fn init(allocator: std.mem.Allocator) Error!Renderer {
        const color_buffer_width: usize = @intCast(WINDOW_WIDTH);
        const color_buffer_height: usize = @intCast(WINDOW_HEIGHT);

        const color_buffer = ColorBuffer.init(allocator, color_buffer_width, color_buffer_height) catch |err| {
            log.err("[Renderer] Error when initializing color buffer: {}", .{err});
            return Error.ColorBufferMemoryLeaked;
        };

        return Renderer{ .allocator = allocator, .render_mode = RenderMode{}, .camera_position = Vec3.zero(), .is_running = false, .prev_frame_time = 0, .triangles_to_render = std.ArrayListUnmanaged(Triangle).empty, .mesh = Mesh.init(allocator), .color_buffer = color_buffer, .color_buffer_texture = undefined };
    }

    pub fn run(self: *Renderer) Error!void {
        try self.setup();
        while (!rl.windowShouldClose() and self.is_running) {
            self.processInput();
            try self.update();
            try self.render();
        }
    }

    pub fn deinit(self: *Renderer) void {
        self.color_buffer.deinit();
        self.mesh.deinit();
        self.triangles_to_render.deinit(self.allocator);
    }

    fn processInput(self: *Renderer) void {
        if (rl.isKeyPressed(.q)) {
            self.is_running = false;
            return;
        }
        if (rl.isKeyPressed(.one)) {
            self.render_mode.toggle(RenderMode{ .wireframe = true });
            return;
        }
        if (rl.isKeyPressed(.two)) {
            self.render_mode.toggle(RenderMode{ .vertices = true });
            return;
        }
        if (rl.isKeyPressed(.three)) {
            self.render_mode.toggle(RenderMode{ .filled_faces = true });
            return;
        }
        if (rl.isKeyPressed(.b)) {
            self.render_mode.toggle(RenderMode{ .backface_culling = true });
            return;
        }
    }

    fn update(self: *Renderer) Error!void {
        // todo: manage time frame
        self.mesh.rotation = self.mesh.rotation.add(Vec3{ .x = 0.01, .y = 0.01, .z = 0.00 });

        for (self.mesh.faces.items) |face| {
            const first_face_vertex: usize = @intCast(face.a);
            const second_face_vertex: usize = @intCast(face.b);
            const third_face_vertex: usize = @intCast(face.c);

            var face_vertices: [3]Vec3 = undefined;
            face_vertices[0] = self.mesh.vertices.items[first_face_vertex - 1];
            face_vertices[1] = self.mesh.vertices.items[second_face_vertex - 1];
            face_vertices[2] = self.mesh.vertices.items[third_face_vertex - 1];

            var transformed_vertices: [3]Vec3 = undefined;
            for (0..3) |i| {
                const vertex: Vec3 = face_vertices[i];
                var transformed_vertex: Vec3 = vertex.rotateX(self.mesh.rotation.x);
                transformed_vertex = transformed_vertex.rotateY(self.mesh.rotation.y);
                transformed_vertex = transformed_vertex.rotateZ(self.mesh.rotation.z);
                transformed_vertex.z = transformed_vertex.z + 5.0;

                transformed_vertices[i] = transformed_vertex;
            }

            var triangle_will_be_rendered: bool = true;
            if (self.render_mode.backface_culling) {
                //    A
                //   / \
                //  C---B
                const vertex_a: Vec3 = transformed_vertices[0];
                const vertex_b: Vec3 = transformed_vertices[1];
                const vertex_c: Vec3 = transformed_vertices[2];
                const vector_ab: Vec3 = vertex_b.sub(vertex_a);
                const vector_ac: Vec3 = vertex_c.sub(vertex_a);

                const vector_ab_norm: Vec3 = vector_ab.normalized();
                const vector_ac_norm: Vec3 = vector_ac.normalized();

                const face_normal: Vec3 = vector_ab_norm.crossProd(vector_ac_norm);
                const face_normal_normalized: Vec3 = face_normal.normalized();

                const camera_ray: Vec3 = self.camera_position.sub(vertex_a);
                const camera_normal_dot: f32 = camera_ray.dotProd(face_normal_normalized);

                if (camera_normal_dot < 0.0) {
                    triangle_will_be_rendered = false;
                }
            }

            if (triangle_will_be_rendered) {
                const average_depth: f32 = (transformed_vertices[0].z + transformed_vertices[1].z + transformed_vertices[2].z) / 3.0;
                var projected_triangle = Triangle{ .v1 = undefined, .v2 = undefined, .v3 = undefined, .depth = average_depth, .color = Color.Yellow };

                var projected_vertex_v1: Vec2 = project(transformed_vertices[0]);
                var projected_vertex_v2: Vec2 = project(transformed_vertices[1]);
                var projected_vertex_v3: Vec2 = project(transformed_vertices[2]);

                const window_width_f: f32 = @floatFromInt(WINDOW_WIDTH);
                const window_height_f: f32 = @floatFromInt(WINDOW_HEIGHT);

                projected_vertex_v1.x = projected_vertex_v1.x + (window_width_f / 2.0);
                projected_vertex_v1.y = projected_vertex_v1.y + (window_height_f / 2.0);
                projected_vertex_v2.x = projected_vertex_v2.x + (window_width_f / 2.0);
                projected_vertex_v2.y = projected_vertex_v2.y + (window_height_f / 2.0);
                projected_vertex_v3.x = projected_vertex_v3.x + (window_width_f / 2.0);
                projected_vertex_v3.y = projected_vertex_v3.y + (window_height_f / 2.0);

                projected_triangle.v1 = projected_vertex_v1;
                projected_triangle.v2 = projected_vertex_v2;
                projected_triangle.v3 = projected_vertex_v3;

                self.triangles_to_render.append(self.allocator, projected_triangle) catch |err| {
                    log.err("[Renderer] Error when projecting triangle: {}", .{err});
                    return Error.TrianglesArrayOutOfMemory;
                };
            }
        }
    }

    fn project(projectable: Vec3) Vec2 {
        return Vec2{ .x = (FOV_FACTOR * projectable.x) / projectable.z, .y = (FOV_FACTOR * projectable.y) / projectable.z };
    }

    fn setup(self: *Renderer) Error!void {
        log.info("[Renderer] Setup...", .{});
        rl.setConfigFlags(.{ .window_highdpi = true, .window_resizable = false, .vsync_hint = true });
        rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Renderer");
        rl.setTargetFPS(FPS);

        log.info("[Renderer] Loading OBJ file into mesh", .{});

        self.mesh.loadOBJ(self.allocator, "resources/meshes/f22.obj") catch |err| {
            log.err("[Renderer] Error while loading mesh from OBJ file: {}", .{err});
            return Error.MeshLoadingFailed;
        };

        log.info("[Renderer] Mesh faces loaded: {}", .{self.mesh.faces.items.len});
        log.info("[Renderer] Mesh vertices loaded: {}", .{self.mesh.vertices.items.len});

        log.info("[Renderer] Loading texture from color buffer", .{});

        const image = rl.Image{
            .data = self.color_buffer.b.items.ptr,
            .width = WINDOW_WIDTH,
            .height = WINDOW_HEIGHT,
            .mipmaps = 1,
            .format = rl.PixelFormat.uncompressed_r8g8b8a8,
        };
        self.color_buffer_texture = rl.loadTextureFromImage(image) catch |err| {
            log.err("[Renderer] Error while loading color buffer texture: {}", .{err});
            return Error.ColorBufferTextureLoadingFailed;
        };
        rl.setTextureFilter(self.color_buffer_texture, rl.TextureFilter.point);

        log.info("[Renderer] Setup completed", .{});

        self.render_mode.toggle(RenderMode{ .wireframe = true });

        self.is_running = true;
    }

    fn render(self: *Renderer) Error!void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        self.color_buffer.drawGrid() catch |err| {
            log.err("[Renderer] Error rendering grid: {}", .{err});
            return Error.ColorBufferMemoryLeaked;
        };

        for (self.triangles_to_render.items) |triangle| {
            const v1_x: usize = @intFromFloat(triangle.v1.x);
            const v1_y: usize = @intFromFloat(triangle.v1.y);
            const v2_x: usize = @intFromFloat(triangle.v2.x);
            const v2_y: usize = @intFromFloat(triangle.v2.y);
            const v3_x: usize = @intFromFloat(triangle.v3.x);
            const v3_y: usize = @intFromFloat(triangle.v3.y);

            if (self.render_mode.wireframe) {
                self.color_buffer.drawTriangle(v1_x, v1_y, v2_x, v2_y, v3_x, v3_y, Color.Red) catch |err| {
                    log.err("[Renderer] Error rendering a triangle: {}", .{err});
                    return Error.ColorBufferMemoryLeaked;
                };
            }

            if (self.render_mode.vertices) {
                self.color_buffer.drawRectangle(v1_x, v1_y, 3, 3, Color.Red) catch |err| {
                    log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                    return Error.ColorBufferMemoryLeaked;
                };

                self.color_buffer.drawRectangle(v2_x, v2_y, 3, 3, Color.Red) catch |err| {
                    log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                    return Error.ColorBufferMemoryLeaked;
                };

                self.color_buffer.drawRectangle(v3_x, v3_y, 3, 3, Color.Red) catch |err| {
                    log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                    return Error.ColorBufferMemoryLeaked;
                };
            }

            if (self.render_mode.filled_faces) {
                self.color_buffer.drawFilledTriangle(v1_x, v1_y, v2_x, v2_y, v3_x, v3_y, Color.Yellow) catch |err| {
                    log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                    return Error.ColorBufferMemoryLeaked;
                };
            }
        }

        self.triangles_to_render.clearRetainingCapacity();

        self.renderColorBuffer();

        self.color_buffer.clear(Color.Black) catch |err| {
            log.err("[Renderer] Error clearing the color buffer: {}", .{err});
            return Error.ColorBufferMemoryLeaked;
        };
    }

    fn renderColorBuffer(self: *Renderer) void {
        rl.updateTexture(self.color_buffer_texture, self.color_buffer.b.items.ptr);
        rl.drawTextureEx(self.color_buffer_texture, rl.Vector2{ .x = 0, .y = 0 }, 0.0, 1.0, rl.Color.white);
    }
};
