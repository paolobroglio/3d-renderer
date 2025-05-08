//
// Created by Paolo Broglio on 08/05/25.
//

#ifndef MESH_H
#define MESH_H

#define N_MESH_VERTICES 8
#define N_MESH_FACES (6 * 2) // 6 faces, each face has two triangles

#include "triangle.h"
#include "vector.h"

extern vec3_t mesh_vertices[N_MESH_VERTICES];
extern face_t mesh_faces[N_MESH_FACES];

#endif //MESH_H
