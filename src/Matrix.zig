const Vec4 = @import("Vec4.zig");

m: [4][4]f32,

const Matrix = @This();

pub fn zero() Matrix {
    return Matrix {
        .m = [4][4]f32 {
            [_]f32{ 0.0, 0.0, 0.0, 0.0},
            [_]f32{ 0.0, 0.0, 0.0, 0.0},
            [_]f32{ 0.0, 0.0, 0.0, 0.0},
            [_]f32{ 0.0, 0.0, 0.0, 0.0},
        }
    };
}

pub fn identity() Matrix {
    return Matrix {
        .m = [4][4]f32 {
            [_]f32{ 1.0, 0.0, 0.0, 0.0},
            [_]f32{ 0.0, 1.0, 0.0, 0.0},
            [_]f32{ 0.0, 0.0, 1.0, 0.0},
            [_]f32{ 0.0, 0.0, 0.0, 1.0},
        }
    };
}

pub fn scale(sx: f32, sy: f32, sz: f32) Matrix {
    return Matrix {
        .m = [4][4]f32 {
            [_]f32{ 1.0 * sx,   0.0,      0.0,   0.0},
            [_]f32{    0.0,  1.0 * sy,    0.0,   0.0},
            [_]f32{    0.0,     0.0,   1.0 * sz, 0.0},
            [_]f32{    0.0,     0.0,      0.0,   1.0},
        }
    };
}

pub fn translate(sx: f32, sy: f32, sz: f32) Matrix {
    return Matrix {
        .m = [4][4]f32 {
            [_]f32{ 1.0, 0.0, 0.0, sx},
            [_]f32{ 0.0, 1.0, 0.0, sy},
            [_]f32{ 0.0, 0.0, 1.0, sz},
            [_]f32{ 0.0, 0.0, 0.0, 1.0},
        }
    };
}

pub fn multiplyByVec4(self: *const Matrix, vec4: Vec4) Vec4 {
    return Vec4 {
        .x = self.m[0][0] * vec4.x + self.m[0][1] * vec4.y + self.m[0][2] * vec4.z + self.m[0][3] * vec4.w,
        .y = self.m[1][0] * vec4.x + self.m[1][1] * vec4.y + self.m[1][2] * vec4.z + self.m[1][3] * vec4.w,
        .z = self.m[2][0] * vec4.x + self.m[2][1] * vec4.y + self.m[2][2] * vec4.z + self.m[2][3] * vec4.w,
        .w = self.m[3][0] * vec4.x + self.m[3][1] * vec4.y + self.m[3][2] * vec4.z + self.m[3][3] * vec4.w
    };
}

