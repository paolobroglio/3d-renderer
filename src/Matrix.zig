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

pub fn rotateZ(angle: f32) Matrix {
    const cos_a: f32 = @cos(angle);
    const sin_a: f32 = @sin(angle);

    return Matrix {
        .m = [4][4]f32 {
            [_]f32{ cos_a, -sin_a, 0.0, 0.0},
            [_]f32{ sin_a, cos_a, 0.0, 0.0},
            [_]f32{ 0.0, 0.0, 1.0, 0.0},
            [_]f32{ 0.0, 0.0, 0.0, 1.0},
        }
    };
}

pub fn rotateX(angle: f32) Matrix {
    const cos_a: f32 = @cos(angle);
    const sin_a: f32 = @sin(angle);

    return Matrix {
        .m = [4][4]f32 {
            [_]f32{ 1.0, 0.0, 0.0, 0.0},
            [_]f32{ 0.0, cos_a, -sin_a, 0.0},
            [_]f32{ 0.0, sin_a, cos_a, 0.0},
            [_]f32{ 0.0, 0.0, 0.0, 1.0},
        }
    };
}

pub fn rotateY(angle: f32) Matrix {
    const cos_a: f32 = @cos(angle);
    const sin_a: f32 = @sin(angle);

    return Matrix {
        .m = [4][4]f32 {
            [_]f32{ cos_a, 0.0, sin_a, 0.0},
            [_]f32{ 0.0, 1.0, 0.0, 0.0},
            [_]f32{ -sin_a, 0.0, cos_a, 0.0},
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

pub fn mul(self: *const Matrix, b: Matrix) Matrix {
    var id: Matrix = identity();

    for (0..4) |i| {
        for (0..4) |j| {
            id.m[i][j] = self.m[i][0] * b.m[0][j] + self.m[i][1] * b.m[1][j] + self.m[i][2] * b.m[2][j] + self.m[i][3] * b.m[3][j];
        }
    }

    return id;
}
