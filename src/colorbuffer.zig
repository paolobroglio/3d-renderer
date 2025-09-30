const std = @import("std");
const mem = std.mem;
const Color = @import("color.zig").Color;

pub const ColorBuffer = struct {
    maxX: usize,
    maxY: usize,
    b: std.ArrayList(u32),

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) ColorBuffer {
        return ColorBuffer{
            .maxX = width,
            .maxY = height,
            .b = std.ArrayList(u32).initCapacity(allocator, width * height)
        };
    }

    pub fn free(self: *ColorBuffer) void {
        self.b.deinit();
    }

    pub fn drawPixel(self: *ColorBuffer, x: usize, y: usize, color: Color) void {
        if (x >= 0 and x < self.maxX and y >= 0 and y < self.maxY) {
            self.setColor(y * self.maxX + y, color);
        }
    }

    pub fn drawGrid(self: *ColorBuffer) void {
        var y_i: usize = 0;
        while (y_i < self.maxY) |y| : (y_i += 10) {
            var x_i: usize = 0;
            while (x_i < self.maxX) |x| : (x_i += 10) {
                self.drawPixel(x, y, Color.LightBlack);
            }
        }
    }

    pub fn drawRectangle(self: *ColorBuffer, x: usize, y: usize, height: usize, width: usize, color: Color) void {
        for (0..width) |i| {
            for (0..height) |j| {
                const curr_x = x + i;
                const curr_y = y + j;

                self.drawPixel(curr_x, curr_y, color);
            }
        }
    }

    pub fn drawLine(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, color: Color) void {
        const dx: usize = x1 - x0;
        const dy: usize = y1 - y0;

        const abs_dx: usize = @abs(dx);
        const abs_dy: usize = @abs(dy);
        const step: usize = if (abs_dx > abs_dy) abs_dx else abs_dy;

        const dx_f: f32 = @floatFromInt(dx);
        const dy_f: f32 = @floatFromInt(dy);
        const step_f: f32 = @floatFromInt(step);

        const x_step: f32 = dx_f / step_f;
        const y_step: f32 = dy_f / step_f;

        var current_x: f32 = @floatFromInt(x0);
        var current_y: f32 = @floatFromInt(y0);

        var i: usize = 0;
        while (i < step) {
            const x: usize = @intFromFloat(current_x);
            const y: usize = @intFromFloat(current_y);

            self.drawPixel(x, y, color);

            current_x += x_step;
            current_y += y_step;
            i += 1;
        }
    }

    pub fn drawTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) void {
        self.drawLine(x0, y0, x1, y1, color);
        self.drawLine(x1, y1, x2, y2, color);
        self.drawLine(x2, y2, x0, y0, color);
    }

    pub fn drawFilledTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) void {
        if (y0 > y1) {
            mem.swap(usize, &y0, &y1);
            mem.swap(usize, &x0, &x1);
        }
        if (y1 > y2) {
            mem.swap(usize, &y1, &y2);
            mem.swap(usize, &x1, &x2);
        }
        if (y0 > y1) {
            mem.swap(usize, &y0, &y1);
            mem.swap(usize, &x0, &x1);
        }
        if (y1 == y2) {
            self.fillFlatBottomTriangle(x0, y0, x1, y1, x2, y2, color);
        } else if (y0 == y1) {
            self.fillFlatTopTriangle(x0, y0, x1, y1, x2, y2, color);
        } else {
            const m_y: usize = y1;
            const m_x_numerator: f32 = @floatFromInt((x2 - x0) * (y1 - y0));
            const m_x_denominator: f32 = @floatFromInt(y2 - y0);
            const x0_f: f32 = @floatFromInt(x0);
            const m_x: f32 = m_x_numerator / m_x_denominator + x0_f;

            self.fillFlatBottomTriangle(x0, y0, x1, y1, m_x, m_y, color);
            self.fillFlatTopTriangle(x1, y1, m_x, m_y, x2, y2, color);
        }
    }

    pub fn clear(self: *ColorBuffer, color: Color) void {
        for (self.b, 0..) |_, i| {
            self.setColor(i, color);
        }
    }

    fn fillFlatBottomTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) void {
        const slope_1_numerator: f32 = @floatFromInt(x1 - x0);
        const slope_1_denominator: f32 = @floatFromInt(y1 - y0);
        const slope_1: f32 = slope_1_numerator / slope_1_denominator;

        const slope_2_numerator: f32 = @floatFromInt(x2 - x0);
        const slope_2_denominator: f32 = @floatFromInt(y2 - y0);
        const slope_2: f32 = slope_2_numerator / slope_2_denominator;

        var x_start: f32 = @floatFromInt(x0);
        var x_end: f32 = @floatFromInt(x0);

        for (y0..y2) |y| {
            const x_start_us: usize = @intFromFloat(x_start);
            const x_end_us: usize = @intFromFloat(x_end);

            self.drawLine(x_start_us, y, x_end_us, y, color);

            x_start += slope_1;
            x_end += slope_2;
        }

    }

    fn fillFlatTopTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) void {
        const slope_1_numerator: f32 = @floatFromInt(x2 - x0);
        const slope_1_denominator: f32 = @floatFromInt(y2 - y0);
        const slope_1: f32 = slope_1_numerator / slope_1_denominator;

        const slope_2_numerator: f32 = @floatFromInt(x2 - x1);
        const slope_2_denominator: f32 = @floatFromInt(y2 - y1);
        const slope_2: f32 = slope_2_numerator / slope_2_denominator;

        var x_start: f32 = @floatFromInt(x2);
        var x_end: f32 = @floatFromInt(x2);

        var y_idx: usize = y2;
        while (y_idx >= y0) |y| : (y_idx -= 1) {
            const x_start_us: usize = @intFromFloat(x_start);
            const x_end_us: usize = @intFromFloat(x_end);

            self.drawLine(x_start_us, y, x_end_us, y, color);

            x_start -= slope_1;
            x_end -= slope_2;
        }

    }

    fn setColor(self: *ColorBuffer, pos: usize, color: Color) void {
        self.b.items[pos] = color;
    }
};