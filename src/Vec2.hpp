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

    float getX() const;

    float getY() const;

    void setX(float x);

    void setY(float y);

    friend std::ostream& operator<<(std::ostream& os, const Vec2& vec);
};


#endif //VEC2_HPP
