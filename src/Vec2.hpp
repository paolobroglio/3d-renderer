//
// Created by Paolo Broglio on 16/05/25.
//

#ifndef VEC2_HPP
#define VEC2_HPP
#include <iosfwd>


class Vec2 {
private:
    float x, y;

public:
    Vec2();

    Vec2(float x, float y);

    float getMagnitude() const;

    Vec2 normalized() const;

    Vec2 cross(const Vec2 &other) const;

    float dot(const Vec2 &other) const;

    float getX() const;

    float getY() const;

    void setX(float x);

    void setY(float y);

    Vec2 operator+(const Vec2 &other) const;
    Vec2 operator-(const Vec2 &other) const;
    Vec2 operator/(float scalar) const;
    Vec2 operator*(float scalar) const;
    friend std::ostream& operator<<(std::ostream& os, const Vec2& vec);
};


#endif //VEC2_HPP
