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

float Vec3::getX() const {
    return this->x;
}

float Vec3::getY() const {
    return this->y;
}

float Vec3::getZ() const {
    return this->z;
}
