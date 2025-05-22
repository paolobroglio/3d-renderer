//
// Created by Paolo Broglio on 17/05/25.
//

#ifndef TRIANGLE_HPP
#define TRIANGLE_HPP
#include <iosfwd>

#include "Vec2.hpp"

typedef struct {
    int a;
    int b;
    int c;
} face_t;


class Triangle {
private:
    Vec2 vertices[3];

public:
    Triangle();
    Triangle(Vec2 a, Vec2 b, Vec2 c);

    Vec2 getVertex(int i) const;
    void setVertex(int i, Vec2 v);

    friend std::ostream& operator<<(std::ostream& os, const Triangle& t);
};

#endif //TRIANGLE_HPP
