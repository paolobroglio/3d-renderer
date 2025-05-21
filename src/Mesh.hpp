//
// Created by Paolo Broglio on 17/05/25.
//

#ifndef MESH_HPP
#define MESH_HPP
#include "Triangle.hpp"
#include "Vec3.hpp"
#include <vector>


class Mesh {
private:
    std::vector<Vec3> vertices;
    std::vector<face_t> faces;
    Vec3 rotation = Vec3(0, 0, 0);

public:
    Mesh() = default;

    Mesh(const std::vector<Vec3> &vertices, const std::vector<face_t> &faces, const Vec3 &rotation);

    ~Mesh() = default;

    void setRotation(Vec3 vec3);

    static Mesh loadOBJ(const std::string &filename);

    std::vector<Vec3> getVertices();

    std::vector<face_t> getFaces();

    Vec3 getRotation();
};


#endif //MESH_HPP
