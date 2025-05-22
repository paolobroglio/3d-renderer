//
// Created by Paolo Broglio on 16/05/25.
//

#include "Vec2.hpp"
#include <iostream>

Vec2::Vec2() : x(0), y(0) {
}

Vec2::Vec2(float x, float y) : x(x), y(y) {
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

std::ostream & operator<<(std::ostream &os, const Vec2 &vec) {
    os << "Vec2(x=" << vec.getX() << ", y=" << vec.getY() << ")";
    return os;
}
