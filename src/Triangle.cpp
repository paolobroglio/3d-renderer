//
// Created by Paolo Broglio on 17/05/25.
//

#include "Triangle.hpp"
#include <iostream>

Triangle::Triangle(const Color color, const float avg_depth): vertices{}, color(color), avg_depth(avg_depth) {
}

Triangle::Triangle(const Vec2 a, const Vec2 b, const Vec2 c, Color color, float avg_depth): vertices{}, color(color), avg_depth(avg_depth) {
    this->vertices[0] = a;
    this->vertices[1] = b;
    this->vertices[2] = c;
}

Vec2 Triangle::getVertex(const int i) const {
    return this->vertices[i];
}

Color Triangle::getColor() const {
    return this->color;
}

float Triangle::getAvgDepth() const {
    return this->avg_depth;
}

void Triangle::setVertex(const int i, const Vec2 v) {
    this->vertices[i] = v;
}

std::ostream & operator<<(std::ostream &os, const Triangle &t) {
    os << "Triangle(v0=" << t.getVertex(0) << ", v1=" << t.getVertex(1) << ", v2=" << t.getVertex(2);
    return os;
}
