const std = @import("std");
const log = std.log;
const rl = @import("raylib");
const Color = @import("color.zig").Color;
const ColorBuffer = @import("colorbuffer.zig").ColorBuffer;
const Mesh = @import("mesh.zig").Mesh;
const Triangle = @import("triangle.zig").Triangle;
const Vec3 = @import("vec3.zig").Vec3;

const WINDOW_WIDTH: u32 = 800;
const WINDOW_HEIGHT: u32 = 600;
const FPS: u32 = 60;
const FOV_FACTOR: u32 = 640;

pub const Error = error{ Initialization, Running, MeshLoadingNotLoaded, ColorBufferNotInitialized, Render };

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
            //self.update();
            //self.render();
            try self.render();
        }
        //self.cleanup();
    }

    pub fn deinit(self: *Renderer) void {
        self.color_buffer.deinit();
        self.mesh.deinit();
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
    //
    // fn update(self: *Renderer) void {
    //
    // }

    fn setup(self: *Renderer) Error!void {
        log.info("[Renderer] Setup...", .{});
        rl.setConfigFlags(.{ .window_highdpi = true, .window_resizable = false, .vsync_hint = true });
        rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Renderer");
        rl.setTargetFPS(FPS);

        log.info("[Renderer] Loading OBJ file into mesh", .{});

        self.mesh.loadOBJ(self.allocator, "resources/meshes/cube.obj") catch |err| {
            log.err("[Renderer] Error while loading mesh from OBJ file: {}", .{err});
            return Error.MeshLoadingNotLoaded;
        };

        log.info("[Renderer] Loading texture from color buffer", .{});

        self.color_buffer_texture = rl.loadTextureFromImage(rl.genImageColor(WINDOW_WIDTH, WINDOW_HEIGHT, rl.Color.black)) catch |err| {
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

            self.color_buffer.drawTriangle(v1_x, v1_y, v2_x, v2_y, v3_x, v3_y, Color.White) catch |err| {
                log.err("[Renderer] Error rendering a triangle: {}", .{err});
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
