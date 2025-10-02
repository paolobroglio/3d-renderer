const std = @import("std");
const log = std.log;
const rl = @import("raylib");
const Color = @import("color.zig").Color;
const ColorBuffer = @import("colorbuffer.zig").ColorBuffer;
const mesh = @import("mesh.zig");
const Mesh = mesh.Mesh;
const Face = mesh.Face;
const Triangle = @import("triangle.zig").Triangle;
const Vec3 = @import("vec3.zig").Vec3;
const Vec2 = @import("vec2.zig").Vec2;

const WINDOW_WIDTH: u32 = 800;
const WINDOW_HEIGHT: u32 = 600;
const FPS: u32 = 60;
const FOV_FACTOR: f32 = 640.0;

pub const Error = error{ Initialization, Running, MeshLoadingNotLoaded, ColorBufferNotInitialized, Render, Projection };

pub const RenderMode = enum { None, Wireframe, Vertices, FilledFaces, BackfaceCulling };

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
            return Error.ColorBufferNotInitialized;
        };

        return Renderer{ .allocator = allocator, .render_mode = RenderMode.None, .camera_position = Vec3.zero(), .is_running = false, .prev_frame_time = 0, .triangles_to_render = std.ArrayListUnmanaged(Triangle).empty, .mesh = Mesh.init(allocator), .color_buffer = color_buffer, .color_buffer_texture = undefined };
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
        // todo: proper toggle render modes
        if (rl.isKeyDown(.q)) {
            self.is_running = false;
            return;
        }
        if (rl.isKeyDown(.one)) {
            self.render_mode = RenderMode.Wireframe;
            return;
        }
        if (rl.isKeyDown(.two)) {
            self.render_mode = RenderMode.Vertices;
            return;
        }
        if (rl.isKeyDown(.three)) {
            self.render_mode = RenderMode.FilledFaces;
            return;
        }
        if (rl.isKeyDown(.b)) {
            self.render_mode = RenderMode.BackfaceCulling;
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
            for (0..3) |i| { // todo: maybe this for can be removed
                const vertex: Vec3 = face_vertices[i];
                var transformed_vertex: Vec3 = vertex.rotateX(self.mesh.rotation.x);
                transformed_vertex = transformed_vertex.rotateY(self.mesh.rotation.y);
                transformed_vertex = transformed_vertex.rotateZ(self.mesh.rotation.z);
                transformed_vertex.z = transformed_vertex.z + 5.0;

                transformed_vertices[i] = transformed_vertex;
            }

            // todo: add Backface Culling processing

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
                return Error.Projection;
            };
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
            return Error.MeshLoadingNotLoaded;
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
            return Error.ColorBufferNotInitialized;
        };
        rl.setTextureFilter(self.color_buffer_texture, rl.TextureFilter.point);

        log.info("[Renderer] Setup completed", .{});

        self.is_running = true;
    }

    fn render(self: *Renderer) Error!void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        self.color_buffer.drawGrid() catch |err| {
            log.err("[Renderer] Error rendering grid: {}", .{err});
            return Error.Render;
        };

        for (self.triangles_to_render.items) |triangle| {
            const v1_x: usize = @intFromFloat(triangle.v1.x);
            const v1_y: usize = @intFromFloat(triangle.v1.y);
            const v2_x: usize = @intFromFloat(triangle.v2.x);
            const v2_y: usize = @intFromFloat(triangle.v2.y);
            const v3_x: usize = @intFromFloat(triangle.v3.x);
            const v3_y: usize = @intFromFloat(triangle.v3.y);

            self.color_buffer.drawTriangle(v1_x, v1_y, v2_x, v2_y, v3_x, v3_y, Color.Red) catch |err| {
                log.err("[Renderer] Error rendering a triangle: {}", .{err});
                return Error.Render;
            };

            self.color_buffer.drawRectangle(v1_x, v1_y, 3, 3, Color.Red) catch |err| {
                log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                return Error.Render;
            };

            self.color_buffer.drawRectangle(v2_x, v2_y, 3, 3, Color.Red) catch |err| {
                log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                return Error.Render;
            };

            self.color_buffer.drawRectangle(v3_x, v3_y, 3, 3, Color.Red) catch |err| {
                log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                return Error.Render;
            };

            self.color_buffer.drawFilledTriangle(v1_x, v1_y, v2_x, v2_y, v3_x, v3_y, Color.Yellow) catch |err| {
                log.err("[Renderer] Error rendering a rectangle: {}", .{err});
                return Error.Render;
            };
        }

        self.triangles_to_render.clearRetainingCapacity();

        self.renderColorBuffer();

        self.color_buffer.clear(Color.Black) catch |err| {
            log.err("[Renderer] Error clearing the color buffer: {}", .{err});
            return Error.Render;
        };
    }

    fn renderColorBuffer(self: *Renderer) void {
        rl.updateTexture(self.color_buffer_texture, self.color_buffer.b.items.ptr);
        rl.drawTextureEx(self.color_buffer_texture, rl.Vector2{ .x = 0, .y = 0 }, 0.0, 1.0, rl.Color.white);
    }
};
