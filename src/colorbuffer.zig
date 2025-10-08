const std = @import("std");
const mem = std.mem;
const Color = @import("Color.zig").Color;

const Error = error{ColorBufferOutOfBounds};

pub const ColorBuffer = struct {
    allocator: mem.Allocator,
    maxX: usize,
    maxY: usize,
    b: std.ArrayListUnmanaged(u32),

    pub fn init(allocator: mem.Allocator, width: usize, height: usize) anyerror!ColorBuffer {
        var b = try std.ArrayListUnmanaged(u32).initCapacity(allocator, width * height);
        const black_u32 = @intFromEnum(Color.Black);
        try b.appendNTimes(allocator, black_u32, width * height);

        return ColorBuffer{ .allocator = allocator, .maxX = width, .maxY = height, .b = b };
    }

    pub fn deinit(self: *ColorBuffer) void {
        self.b.deinit(self.allocator);
    }

    pub fn drawPixel(self: *ColorBuffer, x: usize, y: usize, color: Color) Error!void {
        if (x >= 0 and x < self.maxX and y >= 0 and y < self.maxY) {
            try self.setColor(y * self.maxX + x, color);
        }
    }

    pub fn drawGrid(self: *ColorBuffer) Error!void {
        var y_i: usize = 0;
        while (y_i < self.maxY) : (y_i += 10) {
            var x_i: usize = 0;
            while (x_i < self.maxX) : (x_i += 10) {
                try self.drawPixel(x_i, y_i, Color.LightGrey);
            }
        }
    }

    pub fn drawRectangle(self: *ColorBuffer, x: usize, y: usize, height: usize, width: usize, color: Color) Error!void {
        for (0..width) |i| {
            for (0..height) |j| {
                const curr_x = x + i;
                const curr_y = y + j;

                try self.drawPixel(curr_x, curr_y, color);
            }
        }
    }

    pub fn drawLine(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, color: Color) Error!void {
        const x0_i: isize = @intCast(x0);
        const y0_i: isize = @intCast(y0);
        const x1_i: isize = @intCast(x1);
        const y1_i: isize = @intCast(y1);

        const dx: isize = x1_i - x0_i;
        const dy: isize = y1_i - y0_i;

        const abs_dx: isize = @intCast(@abs(dx));
        const abs_dy: isize = @intCast(@abs(dy));
        const step: isize = if (abs_dx > abs_dy) abs_dx else abs_dy;

        const dx_f: f32 = @floatFromInt(dx);
        const dy_f: f32 = @floatFromInt(dy);
        const step_f: f32 = @floatFromInt(step);

        const x_step: f32 = dx_f / step_f;
        const y_step: f32 = dy_f / step_f;

        var current_x: f32 = @floatFromInt(x0);
        var current_y: f32 = @floatFromInt(y0);

        var i: usize = 0;
        const step_usize: usize = @intCast(step);
        while (i < step_usize) : (i += 1) {
            const x: usize = @intCast(@as(isize, @intFromFloat(current_x)));
            const y: usize = @intCast(@as(isize, @intFromFloat(current_y)));

            try self.drawPixel(x, y, color);

            current_x += x_step;
            current_y += y_step;
        }
    }

    pub fn drawTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) Error!void {
        try self.drawLine(x0, y0, x1, y1, color);
        try self.drawLine(x1, y1, x2, y2, color);
        try self.drawLine(x2, y2, x0, y0, color);
    }

    pub fn drawFilledTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) Error!void {
        var mx0 = x0;
        var my0 = y0;
        var mx1 = x1;
        var my1 = y1;
        var mx2 = x2;
        var my2 = y2;

        if (my0 > my1) {
            mem.swap(usize, &my0, &my1);
            mem.swap(usize, &mx0, &mx1);
        }
        if (my1 > my2) {
            mem.swap(usize, &my1, &my2);
            mem.swap(usize, &mx1, &mx2);
        }
        if (my0 > my1) {
            mem.swap(usize, &my0, &my1);
            mem.swap(usize, &mx0, &mx1);
        }

        if (my1 == my2) {
            try self.fillFlatBottomTriangle(mx0, my0, mx1, my1, mx2, my2, color);
        } else if (my0 == my1) {
            try self.fillFlatTopTriangle(mx0, my0, mx1, my1, mx2, my2, color);
        } else {
            const m_y: usize = my1;
            const mx0_i: isize = @intCast(mx0);
            const my0_i: isize = @intCast(my0);
            const mx2_i: isize = @intCast(mx2);
            const my1_i: isize = @intCast(my1);
            const my2_i: isize = @intCast(my2);

            const m_x_numerator: f32 = @floatFromInt((mx2_i - mx0_i) * (my1_i - my0_i));
            const m_x_denominator: f32 = @floatFromInt(my2_i - my0_i);
            const x0_f: f32 = @floatFromInt(mx0);
            const m_x_f: f32 = m_x_numerator / m_x_denominator + x0_f;
            const m_x: usize = @intCast(@as(isize, @intFromFloat(m_x_f)));

            try self.fillFlatBottomTriangle(mx0, my0, mx1, my1, m_x, m_y, color);
            try self.fillFlatTopTriangle(mx1, my1, m_x, m_y, mx2, my2, color);
        }
    }

    pub fn clear(self: *ColorBuffer, color: Color) Error!void {
        for (self.b.items, 0..) |_, i| {
            try self.setColor(i, color);
        }
    }

    fn fillFlatBottomTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) Error!void {
        const x0_i: isize = @intCast(x0);
        const y0_i: isize = @intCast(y0);
        const x1_i: isize = @intCast(x1);
        const y1_i: isize = @intCast(y1);
        const x2_i: isize = @intCast(x2);
        const y2_i: isize = @intCast(y2);

        const slope_1_numerator: f32 = @floatFromInt(x1_i - x0_i);
        const slope_1_denominator: f32 = @floatFromInt(y1_i - y0_i);
        const slope_1: f32 = slope_1_numerator / slope_1_denominator;

        const slope_2_numerator: f32 = @floatFromInt(x2_i - x0_i);
        const slope_2_denominator: f32 = @floatFromInt(y2_i - y0_i);
        const slope_2: f32 = slope_2_numerator / slope_2_denominator;

        var x_start: f32 = @floatFromInt(x0);
        var x_end: f32 = @floatFromInt(x0);

        for (y0..y2 + 1) |y| {
            const x_start_us: usize = @intCast(@as(isize, @intFromFloat(x_start)));
            const x_end_us: usize = @intCast(@as(isize, @intFromFloat(x_end)));

            try self.drawLine(x_start_us, y, x_end_us, y, color);

            x_start += slope_1;
            x_end += slope_2;
        }
    }

    fn fillFlatTopTriangle(self: *ColorBuffer, x0: usize, y0: usize, x1: usize, y1: usize, x2: usize, y2: usize, color: Color) Error!void {
        const x0_i: isize = @intCast(x0);
        const y0_i: isize = @intCast(y0);
        const x1_i: isize = @intCast(x1);
        const y1_i: isize = @intCast(y1);
        const x2_i: isize = @intCast(x2);
        const y2_i: isize = @intCast(y2);

        const slope_1_numerator: f32 = @floatFromInt(x2_i - x0_i);
        const slope_1_denominator: f32 = @floatFromInt(y2_i - y0_i);
        const slope_1: f32 = slope_1_numerator / slope_1_denominator;

        const slope_2_numerator: f32 = @floatFromInt(x2_i - x1_i);
        const slope_2_denominator: f32 = @floatFromInt(y2_i - y1_i);
        const slope_2: f32 = slope_2_numerator / slope_2_denominator;

        var x_start: f32 = @floatFromInt(x2);
        var x_end: f32 = @floatFromInt(x2);

        var y: isize = y2_i;
        while (y >= y0_i) : (y -= 1) {
            const x_start_us: usize = @intCast(@as(isize, @intFromFloat(x_start)));
            const x_end_us: usize = @intCast(@as(isize, @intFromFloat(x_end)));
            const y_us: usize = @intCast(y);

            try self.drawLine(x_start_us, y_us, x_end_us, y_us, color);

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
