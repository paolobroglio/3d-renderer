//
// Created by Paolo Broglio on 16/05/25.
//

#include "Vec2.hpp"

Vec2::Vec2(float x, float y) : x(x), y(y) {
}

float Vec2::getX() const {
    return this->x;
}

float Vec2::getY() const {
    return this->y;
}
