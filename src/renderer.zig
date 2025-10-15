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
const Vec4 = @import("Vec4.zig");
const Matrix = @import("Matrix.zig");

const WINDOW_WIDTH: u32 = 800;
const WINDOW_HEIGHT: u32 = 600;
const FPS: u32 = 60;
const FOV_FACTOR: f32 = 640.0;

const FOV: f32 = std.math.pi / 3.0;
const WHEIGHT_F: f32 = @floatFromInt(WINDOW_HEIGHT);
const WWIDTH_F: f32 = @floatFromInt(WINDOW_WIDTH);
const ASPECT: f32 = WHEIGHT_F / WWIDTH_F;
const ZNEAR: f32 = 0.1;
const ZFAR: f32 = 100.0;

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
    light_source_direction: Vec3,
    is_running: bool,
    prev_frame_time: u32,

    triangles_to_render: std.ArrayListUnmanaged(Triangle),
    mesh: Mesh,
    projection_matrix: Matrix,
    color_buffer: ColorBuffer,
    color_buffer_texture: rl.Texture2D,

    pub fn init(allocator: std.mem.Allocator) Error!Renderer {
        const color_buffer_width: usize = @intCast(WINDOW_WIDTH);
        const color_buffer_height: usize = @intCast(WINDOW_HEIGHT);

        const color_buffer = ColorBuffer.init(allocator, color_buffer_width, color_buffer_height) catch |err| {
            log.err("[Renderer] Error when initializing color buffer: {}", .{err});
            return Error.ColorBufferMemoryLeaked;
        };

        var light_source_direction = Vec3.zero();
        light_source_direction.z = 1.0;
        const light_dir_norm = light_source_direction.normalized();

        return Renderer{ .allocator = allocator, .render_mode = RenderMode{}, .camera_position = Vec3.zero(), .light_source_direction = light_dir_norm, .is_running = false, .prev_frame_time = 0, .triangles_to_render = std.ArrayListUnmanaged(Triangle).empty, .mesh = Mesh.init(allocator), .projection_matrix = undefined, .color_buffer = color_buffer, .color_buffer_texture = undefined };
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
        self.mesh.rotation = self.mesh.rotation.add(Vec3{ .x = 0.005, .y = 0.000, .z = 0.000 });
        //self.mesh.scale = self.mesh.scale.add(Vec3{ .x = 0.001, .y = 0.001, .z = 0.000 });
        //self.mesh.translation = self.mesh.translation.add(Vec3{ .x = 0.001, .y = 0.00, .z = 0.00 });
        self.mesh.translation.z = 5.0;

        const scale_matrix: Matrix = Matrix.scale(self.mesh.scale.x, self.mesh.scale.y, self.mesh.scale.z);
        const translation_matrix: Matrix = Matrix.translate(self.mesh.translation.x, self.mesh.translation.y, self.mesh.translation.z);
        const rotation_matrix_x: Matrix = Matrix.rotateX(self.mesh.rotation.x);
        const rotation_matrix_y: Matrix = Matrix.rotateY(self.mesh.rotation.y);
        const rotation_matrix_z: Matrix = Matrix.rotateZ(self.mesh.rotation.z);

        for (self.mesh.faces.items) |face| {
            const first_face_vertex: usize = @intCast(face.a);
            const second_face_vertex: usize = @intCast(face.b);
            const third_face_vertex: usize = @intCast(face.c);

            var face_vertices: [3]Vec3 = undefined;
            face_vertices[0] = self.mesh.vertices.items[first_face_vertex - 1];
            face_vertices[1] = self.mesh.vertices.items[second_face_vertex - 1];
            face_vertices[2] = self.mesh.vertices.items[third_face_vertex - 1];

            var transformed_vertices: [3]Vec4 = undefined;
            for (0..3) |i| {
                const vertex: Vec4 = Vec4.fromVec3(face_vertices[i]);

                // TRANSFORMATION ORDER: scale -> rotation -> translation
                var world_matrix: Matrix = Matrix.identity();
                world_matrix = scale_matrix.mul(world_matrix);
                world_matrix = rotation_matrix_x.mul(world_matrix);
                world_matrix = rotation_matrix_y.mul(world_matrix);
                world_matrix = rotation_matrix_z.mul(world_matrix);
                world_matrix = translation_matrix.mul(world_matrix);

                const transformed_vertex = world_matrix.multiplyByVec4(vertex);

                transformed_vertices[i] = transformed_vertex;
            }

            const vertex_a: Vec3 = transformed_vertices[0].toVec3();
            const vertex_b: Vec3 = transformed_vertices[1].toVec3();
            const vertex_c: Vec3 = transformed_vertices[2].toVec3();

            //    A
            //   / \
            //  C---B
            const vector_ab: Vec3 = vertex_b.sub(vertex_a);
            const vector_ac: Vec3 = vertex_c.sub(vertex_a);
            const vector_ab_norm: Vec3 = vector_ab.normalized();
            const vector_ac_norm: Vec3 = vector_ac.normalized();
            const face_normal: Vec3 = vector_ab_norm.crossProd(vector_ac_norm);
            const face_normal_normalized: Vec3 = face_normal.normalized();

            // BACKFACE CULLING
            var triangle_will_be_rendered: bool = true;
            if (self.render_mode.backface_culling) {
                const camera_ray: Vec3 = self.camera_position.sub(vertex_a);
                const camera_normal_dot: f32 = face_normal_normalized.dotProd(camera_ray);

                if (camera_normal_dot < 0.0) {
                    triangle_will_be_rendered = false;
                }
            }

            if (triangle_will_be_rendered) {
                // LIGHTING
                const light_ray: Vec3 = self.light_source_direction.sub(vertex_a);
                const light_normal_dot: f32 = face_normal_normalized.dotProd(light_ray);
                const triangle_color: Color = applyLightIntensity(Color.White, light_normal_dot);

                const average_depth: f32 = (vertex_a.z + vertex_b.z + vertex_c.z) / 3.0;
                var projected_triangle = Triangle{ .v1 = undefined, .v2 = undefined, .v3 = undefined, .depth = average_depth, .color = triangle_color };

                var projected_points: [3]Vec4 = undefined;
                for (0..3) |i| {
                    var proj: Vec4 = self.projection_matrix.perspectiveDivide(transformed_vertices[i]);

                    // Scale
                    proj.x *= (WWIDTH_F / 2.0);
                    proj.y *= (WHEIGHT_F / 2.0);

                    // Invert Y axis
                    proj.y *= -1;

                    // Translate
                    proj.x += (WWIDTH_F / 2.0);
                    proj.y += (WHEIGHT_F / 2.0);

                    projected_points[i] = proj;
                }

                projected_triangle.v1 = Vec2{ .x = projected_points[0].x, .y = projected_points[0].y };
                projected_triangle.v2 = Vec2{ .x = projected_points[1].x, .y = projected_points[1].y };
                projected_triangle.v3 = Vec2{ .x = projected_points[2].x, .y = projected_points[2].y };

                self.triangles_to_render.append(self.allocator, projected_triangle) catch |err| {
                    log.err("[Renderer] Error when projecting triangle: {}", .{err});
                    return Error.TrianglesArrayOutOfMemory;
                };
            }
        }

        std.mem.sort(Triangle, self.triangles_to_render.items, {}, struct {
            fn lessThan(context: void, a: Triangle, b: Triangle) bool {
                _ = context;
                return a.depth > b.depth;
            }
        }.lessThan);
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

        self.projection_matrix = Matrix.perspective(FOV, ASPECT, ZNEAR, ZFAR);

        log.info("[Renderer] Setup completed", .{});

        self.render_mode.toggle(RenderMode{ .backface_culling = true, .filled_faces = true });

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
            // FIXME: panic: integer part of floating point value out of bounds
            const v1_x: i32 = @intFromFloat(triangle.v1.x);
            const v1_y: i32 = @intFromFloat(triangle.v1.y);
            const v2_x: i32 = @intFromFloat(triangle.v2.x);
            const v2_y: i32 = @intFromFloat(triangle.v2.y);
            const v3_x: i32 = @intFromFloat(triangle.v3.x);
            const v3_y: i32 = @intFromFloat(triangle.v3.y);

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
                self.color_buffer.drawFilledTriangle(v1_x, v1_y, v2_x, v2_y, v3_x, v3_y, triangle.color) catch |err| {
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

    fn applyLightIntensity(original_color: Color, light_distance_factor: f32) Color {
        const factor = @min(1.0, @max(0.0, light_distance_factor));

        const color_i: u32 = @intFromEnum(original_color);

        const a: u32 = color_i & 0xFF000000;
        const r: u32 = (color_i >> 16) & 0xFF;
        const g: u32 = (color_i >> 8) & 0xFF;
        const b: u32 = color_i & 0xFF;

        const r_lit: u32 = @intFromFloat(@as(f32, @floatFromInt(r)) * factor);
        const g_lit: u32 = @intFromFloat(@as(f32, @floatFromInt(g)) * factor);
        const b_lit: u32 = @intFromFloat(@as(f32, @floatFromInt(b)) * factor);

        return Color.fromU32(a | (r_lit << 16) | (g_lit << 8) | b_lit);
    }
};
