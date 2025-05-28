//
// Created by Paolo Broglio on 16/05/25.
//

#ifndef VEC3_HPP
#define VEC3_HPP

class Vec3 {
public:
    Vec3() = default;

    Vec3(float x, float y, float z);

    ~Vec3() = default;

    Vec3 rotateX(float angle) const;

    Vec3 rotateY(float angle) const;

    Vec3 rotateZ(float angle) const;

    float getMagnitude() const;

    Vec3 normalized() const;

    Vec3 cross(const Vec3& other) const;

    float dot(const Vec3& other) const;

    float getX() const;

    float getY() const;

    float getZ() const;

    void setX(float x);

    void setY(float y);

    void setZ(float z);

    Vec3 operator+(const Vec3 &other) const;
    Vec3 operator-(const Vec3 &other) const;
    Vec3 operator*(const Vec3 &other) const;
    Vec3 operator/(float scalar) const;
    Vec3 operator*(float scalar) const;

private:
    float x;
    float y;
    float z;
};


#endif //VEC3_HPP
