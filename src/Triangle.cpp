//
// Created by Paolo Broglio on 17/05/25.
//

#include "Triangle.hpp"

Triangle::Triangle(): vertices{} {
}

Triangle::Triangle(const Vec2 a, const Vec2 b, const Vec2 c): vertices{} {
    this->vertices[0] = a;
    this->vertices[1] = b;
    this->vertices[2] = c;
}

Vec2 Triangle::getVertex(const int i) const {
    return this->vertices[i];
}

void Triangle::setVertex(const int i, const Vec2 v) {
    this->vertices[i] = v;
}

