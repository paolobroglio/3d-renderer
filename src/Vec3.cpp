//
// Created by Paolo Broglio on 16/05/25.
//

#include "Vec3.hpp"

#include <cmath>

Vec3::Vec3(float x, float y, float z) : x(x),
                                        y(y),
                                        z(z) {
}


Vec3 Vec3::rotateX(float angle) const {
    return {
        this->x,
        this->y * cos(angle) - this->z * sin(angle),
        this->y * sin(angle) + this->z * cos(angle)
    };
}

Vec3 Vec3::rotateY(float angle) const {
    return {
        this->x * cos(angle) - this->z * sin(angle),
        this->y,
        this->x * sin(angle) + this->z * cos(angle)
    };
}

Vec3 Vec3::rotateZ(float angle) const {
    return {
        this->x * cos(angle) - this->y * sin(angle),
        this->x * sin(angle) + this->y * cos(angle),
        this->z
    };
}

float Vec3::getMagnitude() const {
    return sqrt(x * x + y * y + z * z);
}

void Vec3::normalize() {
    float magnitude = getMagnitude();
    this->x /= magnitude;
    this->y /= magnitude;
    this->z /= magnitude;
}

Vec3 Vec3::cross(const Vec3 &other) const {
    return {
        this->y * other.z - this->z * other.y,
        this->z * other.x - this->x * other.z,
        this->x * other.y - this->y * other.x
    };
}

float Vec3::dot(const Vec3 &other) const {
    return this->x * other.x + this->y * other.y + this->z * other.z;
}

float Vec3::getX() const {
    return this->x;
}

float Vec3::getY() const {
    return this->y;
}

float Vec3::getZ() const {
    return this->z;
}

void Vec3::setX(float x) {
    this->x = x;
}

void Vec3::setY(float y) {
    this->y = y;
}

void Vec3::setZ(float z) {
    this->z = z;
}

Vec3 Vec3::operator+(const Vec3 &other) const {
    return {x + other.x, y + other.y, z + other.z};
}

Vec3 Vec3::operator-(const Vec3 &other) const {
    return {x - other.x, y - other.y, z - other.z};
}

Vec3 Vec3::operator/(float scalar) const {
    return {x / scalar, y / scalar, z / scalar};
}

Vec3 Vec3::operator*(float scalar) const {
    return {x * scalar, y * scalar, z * scalar};
}
