//
// Created by Paolo Broglio on 17/05/25.
//

#ifndef TRIANGLE_HPP
#define TRIANGLE_HPP
#include <iosfwd>

#include "Color.hpp"
#include "Vec2.hpp"

typedef struct {
    int a;
    int b;
    int c;
} face_t;


class Triangle {
private:
    Vec2 vertices[3];
    Color color;
    float avg_depth{};

public:
    Triangle(Color color, float avg_depth);
    Triangle(Vec2 a, Vec2 b, Vec2 c, Color color, float avg_depth);

    Vec2 getVertex(int i) const;
    Color getColor() const;
    float getAvgDepth() const;
    void setVertex(int i, Vec2 v);

    friend std::ostream& operator<<(std::ostream& os, const Triangle& t);
};

#endif //TRIANGLE_HPP
