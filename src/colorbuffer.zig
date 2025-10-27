const std = @import("std");
const mem = std.mem;
const Color = @import("Color.zig").Color;
const texture = @import("texture.zig");
const UVCoords = texture.UVCoords;

const Error = error{ColorBufferOutOfBounds};

pub const ColorBuffer = struct {
    allocator: mem.Allocator,
    maxX: usize,
    maxY: usize,
    maxX_i: i32,
    maxY_i: i32,
    b: std.ArrayListUnmanaged(u32),

    pub fn init(allocator: mem.Allocator, width: usize, height: usize) anyerror!ColorBuffer {
        var b = try std.ArrayListUnmanaged(u32).initCapacity(allocator, width * height);
        const black_u32 = @intFromEnum(Color.Black);
        try b.appendNTimes(allocator, black_u32, width * height);

        return ColorBuffer{ .allocator = allocator, .maxX = width, .maxY = height, .maxX_i = @as(i32, @intCast(width)), .maxY_i = @as(i32, @intCast(height)), .b = b };
    }

    pub fn deinit(self: *ColorBuffer) void {
        self.b.deinit(self.allocator);
    }

    pub fn drawPixel(self: *ColorBuffer, x: i32, y: i32, color: Color) Error!void {
        if (x >= 0 and x < self.maxX_i and y >= 0 and y < self.maxY_i) {
            const xu: usize = @intCast(x);
            const yu: usize = @intCast(y);
            try self.setColor(yu * self.maxX + xu, color);
        }
    }

    pub fn drawGrid(self: *ColorBuffer) Error!void {
        var y_i: i32 = 0;
        while (y_i < self.maxY_i) : (y_i += 10) {
            var x_i: i32 = 0;
            while (x_i < self.maxX_i) : (x_i += 10) {
                try self.drawPixel(x_i, y_i, Color.LightGrey);
            }
        }
    }

    pub fn drawRectangle(self: *ColorBuffer, x: i32, y: i32, height: i32, width: i32, color: Color) Error!void {
        var x_i: i32 = 0;
        while (x_i < width) : (x_i += 1) {
            var y_i: i32 = 0;
            while (y_i < height) : (y_i += 1) {
                const curr_x = x + x_i;
                const curr_y = y + y_i;

                try self.drawPixel(curr_x, curr_y, color);
            }
        }
    }

    pub fn drawLine(self: *ColorBuffer, x0: i32, y0: i32, x1: i32, y1: i32, color: Color) Error!void {
        const delta_x: i32 = x1 - x0;
        const delta_y: i32 = y1 - y0;

        const abs_dx: i32 = @intCast(@abs(delta_x));
        const abs_dy: i32 = @intCast(@abs(delta_y));
        const step: i32 = if (abs_dx >= abs_dy) abs_dx else abs_dy;

        const deltax_f: f32 = @floatFromInt(delta_x);
        const deltay_f: f32 = @floatFromInt(delta_y);
        const step_f: f32 = @floatFromInt(step);

        const x_step: f32 = deltax_f / step_f;
        const y_step: f32 = deltay_f / step_f;

        var current_x: f32 = @floatFromInt(x0);
        var current_y: f32 = @floatFromInt(y0);

        var i: i32 = 0;
        while (i <= step) : (i += 1) {
            const current_x_i: i32 = @intFromFloat(current_x);
            const current_y_i: i32 = @intFromFloat(current_y);
            try self.drawPixel(current_x_i, current_y_i, color);
            current_x += x_step;
            current_y += y_step;
        }
    }

    pub fn drawTriangle(self: *ColorBuffer, x0: i32, y0: i32, x1: i32, y1: i32, x2: i32, y2: i32, color: Color) Error!void {
        try self.drawLine(x0, y0, x1, y1, color);
        try self.drawLine(x1, y1, x2, y2, color);
        try self.drawLine(x2, y2, x0, y0, color);
    }

    pub fn drawFilledTriangle(self: *ColorBuffer, x0: i32, y0: i32, x1: i32, y1: i32, x2: i32, y2: i32, color: Color) Error!void {
        var mx0: i32 = x0;
        var my0: i32 = y0;
        var mx1: i32 = x1;
        var my1: i32 = y1;
        var mx2: i32 = x2;
        var my2: i32 = y2;

        if (my0 > my1) {
            mem.swap(i32, &my0, &my1);
            mem.swap(i32, &mx0, &mx1);
        }
        if (my1 > my2) {
            mem.swap(i32, &my1, &my2);
            mem.swap(i32, &mx1, &mx2);
        }
        if (my0 > my1) {
            mem.swap(i32, &my0, &my1);
            mem.swap(i32, &mx0, &mx1);
        }

        if (my1 == my2) {
            try self.fillFlatBottomTriangle(mx0, my0, mx1, my1, mx2, my2, color);
        } else if (my0 == my1) {
            try self.fillFlatTopTriangle(mx0, my0, mx1, my1, mx2, my2, color);
        } else {
            const m_y: i32 = my1;
            const m_x: i32 = @divTrunc((mx2 - mx0) * (my1 - my0), my2 - my0) + mx0;

            try self.fillFlatBottomTriangle(mx0, my0, mx1, my1, m_x, m_y, color);
            try self.fillFlatTopTriangle(mx1, my1, m_x, m_y, mx2, my2, color);
        }
    }

    // pub fn drawTexturedTriangle(self: *ColorBuffer, x0: i32, y0: i32, x1: i32, y1: i32, x2: i32, y2: i32, uv_0: UVCoords, uv_1: UVCoords, uv_2: UVCoords, color: Color) Error!void {
    //
    // }

    pub fn clear(self: *ColorBuffer, color: Color) Error!void {
        for (self.b.items, 0..) |_, i| {
            try self.setColor(i, color);
        }
    }

    fn fillFlatBottomTriangle(self: *ColorBuffer, x0: i32, y0: i32, x1: i32, y1: i32, x2: i32, y2: i32, color: Color) Error!void {
        const slope_1_numerator: f32 = @floatFromInt(x1 - x0);
        const slope_1_denominator: f32 = @floatFromInt(y1 - y0);
        const slope_1: f32 = slope_1_numerator / slope_1_denominator;

        const slope_2_numerator: f32 = @floatFromInt(x2 - x0);
        const slope_2_denominator: f32 = @floatFromInt(y2 - y0);
        const slope_2: f32 = slope_2_numerator / slope_2_denominator;

        var x_start: f32 = @floatFromInt(x0);
        var x_end: f32 = @floatFromInt(x0);

        var y: i32 = y0;
        while (y <= y2) : (y += 1) {
            const x_start_i: i32 = @intFromFloat(x_start);
            const x_end_i: i32 = @intFromFloat(x_end);

            try self.drawLine(x_start_i, y, x_end_i, y, color);

            x_start += slope_1;
            x_end += slope_2;
        }
    }

    fn fillFlatTopTriangle(self: *ColorBuffer, x0: i32, y0: i32, x1: i32, y1: i32, x2: i32, y2: i32, color: Color) Error!void {
        const slope_1_numerator: f32 = @floatFromInt(x2 - x0);
        const slope_1_denominator: f32 = @floatFromInt(y2 - y0);
        const slope_1: f32 = slope_1_numerator / slope_1_denominator;

        const slope_2_numerator: f32 = @floatFromInt(x2 - x1);
        const slope_2_denominator: f32 = @floatFromInt(y2 - y1);
        const slope_2: f32 = slope_2_numerator / slope_2_denominator;

        var x_start: f32 = @floatFromInt(x2);
        var x_end: f32 = @floatFromInt(x2);

        var y: i32 = y2;
        while (y >= y0) : (y -= 1) {
            const x_start_i: i32 = @intFromFloat(x_start);
            const x_end_i: i32 = @intFromFloat(x_end);

            try self.drawLine(x_start_i, y, x_end_i, y, color);

            x_start -= slope_1;
            x_end -= slope_2;
        }
    }

    fn setColor(self: *ColorBuffer, pos: usize, color: Color) Error!void {
        if (pos > self.b.capacity) {
            return Error.ColorBufferOutOfBounds;
        }
        self.b.items[pos] = @intFromEnum(color);
    }
};
