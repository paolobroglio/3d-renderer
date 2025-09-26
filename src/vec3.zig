pub const Vec3 = struct {
  x: f32,
  y: f32,
  z: f32,

  pub fn zero() Vec3 {
    return Vec3 {
      .x = 0.0,
      .y = 0.0,
      .z = 0.0
    };
  }

  pub fn magnitude(self: *const Vec3) f32 {
    return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
  }

  pub fn normalized(self: *const Vec3) Vec3 {
    const magni: f32 = self.magnitude();
    return Vec3 {
      .x = self.x / magni,
      .y = self.y / magni,
      .z = self.z / magni
    };
  }

  pub fn crossProd(self: *const Vec3, other: Vec3) Vec3 {
    return Vec3 {
      .x = self.y * other.z - self.z * other.y,
      .y = self.z * other.x - self.x * other.z,
      .z = self.x * other.y - self.y * other.x
    };
  }

  pub fn dotProd(self: *const Vec3, other: Vec3) f32 {
    return self.x * other.x + self.y * other.y + self.z * other.z;
  }

  pub fn add(self: *const Vec3, other: Vec3) Vec3 {
    return Vec3 {
      .x = self.x + other.x,
      .y = self.y + other.y,
      .z = self.z + other.z
    };
  }

  pub fn sub(self: *const Vec3, other: Vec3) Vec3 {
    return Vec3 {
      .x = self.x - other.x,
      .y = self.y - other.y,
      .z = self.z - other.z
    };
  }

  pub fn scalarProd(self: *const Vec3, n: f32) Vec3 {
    return Vec3 {
      .x = self.x * n,
      .y = self.y * n,
      .z = self.z * n
    };
  }

  pub fn scalarDiv(self: *const Vec3, n: f32) Vec3 {
    return self.scalarProd(1/n);
  }
};