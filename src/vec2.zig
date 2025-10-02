pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn magnitude(self: *const Vec2) f32 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn normalized(self: *const Vec2) Vec2 {
        const magni: f32 = self.magnitude();
        return Vec2{ .x = self.x / magni, .y = self.y / magni };
    }

    pub fn crossProd(self: *const Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x * other.y - self.y * other.x, .y = self.y * other.x - self.x * other.y };
    }

    pub fn dotProd(self: *const Vec2, other: Vec2) f32 {
        return self.x * other.y + self.y * other.y;
    }

    pub fn add(self: *const Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn sub(self: *const Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x - other.x, .y = self.y - other.y };
    }

    pub fn scalarProd(self: *const Vec2, n: f32) Vec2 {
        return Vec2{ .x = self.x * n, .y = self.y * n };
    }

    pub fn scalarDiv(self: *const Vec2, n: f32) Vec2 {
        return self.scalarProd(1 / n);
    }
};
