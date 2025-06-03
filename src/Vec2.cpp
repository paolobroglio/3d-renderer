//
// Created by Paolo Broglio on 16/05/25.
//

#include "Vec2.hpp"
#include <iostream>

Vec2::Vec2() : x(0), y(0) {
}

Vec2::Vec2(float x, float y) : x(x), y(y) {
}

float Vec2::getMagnitude() const {
    return sqrt(x * x + y * y);
}

void Vec2::normalize() {
    float magnitude = getMagnitude();
    this->x /= magnitude;
    this->y /= magnitude;
}

Vec2 Vec2::cross(const Vec2 &other) const {
    return  {
        this->x * other.y - this->y * other.x,
        this->y * other.x - this->x * other.y
    };
}

float Vec2::dot(const Vec2 &other) const {
    return this->x * other.x + this->y * other.y;
}

float Vec2::getX() const {
    return this->x;
}

float Vec2::getY() const {
    return this->y;
}

void Vec2::setX(float x) {
    this->x = x;
}

void Vec2::setY(float y) {
    this->y = y;
}

Vec2 Vec2::operator+(const Vec2 &other) const {
    return {x + other.x, y + other.y};
}

Vec2 Vec2::operator-(const Vec2 &other) const {
    return {x - other.x, y - other.y};
}

Vec2 Vec2::operator/(float scalar) const {
    return {x / scalar, y / scalar};
}

Vec2 Vec2::operator*(float scalar) const {
    return {x * scalar, y * scalar};
}

std::ostream & operator<<(std::ostream &os, const Vec2 &vec) {
    os << "Vec2(x=" << vec.getX() << ", y=" << vec.getY() << ")";
    return os;
}
