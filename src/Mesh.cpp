//
// Created by Paolo Broglio on 17/05/25.
//

#include "Mesh.hpp"

#include <iostream>
#include <ostream>

Mesh::Mesh(const std::vector<Vec3> &vertices, const std::vector<face_t> &faces, const Vec3 &rotation) : vertices(vertices), faces(faces), rotation(rotation) {
}

void Mesh::setRotation(Vec3 vec3) {
    rotation = vec3;
}

Mesh Mesh::loadOBJ(const std::string &filename) {
    FILE *file = fopen(filename.c_str(), "r");
    if (!file) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }

    Mesh mesh;

    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        if (strncmp(line, "v ", 2) == 0) {
            float x, y, z;
            sscanf(line, "v %f %f %f", &x, &y, &z);
            mesh.vertices.push_back(Vec3(x, y, z));
        }
        if (strncmp(line, "f ", 2) == 0) {
            int vertex_indeces[3];
            int texture_indeces[3];
            int normal_indeces[3];
            sscanf(line, "f %d/%d/%d %d/%d/%d %d/%d/%d",
                &vertex_indeces[0], &texture_indeces[0], &normal_indeces[0],
                &vertex_indeces[1], &texture_indeces[1], &normal_indeces[1],
                &vertex_indeces[2], &texture_indeces[2], &normal_indeces[2]
                );
            face_t face = {
                .a = vertex_indeces[0],
                .b = vertex_indeces[1],
                .c = vertex_indeces[2]
            };
            mesh.faces.push_back(face);
        }
    }
    fclose(file);
    std::cout << "Loaded Mesh: " << filename << std::endl;
    return mesh;
}

std::vector<Vec3> Mesh::getVertices() {
    return vertices;
}

std::vector<face_t> Mesh::getFaces() {
    return faces;
}

Vec3 Mesh::getRotation() {
    return rotation;
}
