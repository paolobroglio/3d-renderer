//
// Created by Paolo Broglio on 16/05/25.
//

#ifndef VEC3_HPP
#define VEC3_HPP

class Vec3 {
public:
    Vec3() = default;

    Vec3(float x, float y, float z);

    ~Vec3() = default;

    Vec3 rotateX(float angle) const;

    Vec3 rotateY(float angle) const;

    Vec3 rotateZ(float angle) const;

    float getX() const;

    float getY() const;

    float getZ() const;

    void setX(float x);

    void setY(float y);

    void setZ(float z);

private:
    float x;
    float y;
    float z;
};


#endif //VEC3_HPP
