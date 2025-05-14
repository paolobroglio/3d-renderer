//
// Created by Paolo Broglio on 08/05/25.
//
#include "mesh.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "array.h"

vec3_t cube_vertices[N_CUBE_VERTICES] = {
    { .x = -1, .y = -1, .z = -1 },
    { .x = -1, .y = 1, .z = -1 },
    { .x = 1, .y = 1, .z = -1 },
    { .x = 1, .y = -1, .z = -1 },
    { .x = 1, .y = 1, .z = 1 },
    { .x = 1, .y = -1, .z = 1 },
    { .x = -1, .y = 1, .z = 1 },
    { .x = -1, .y = -1, .z = 1 },
};

face_t cube_faces[N_CUBE_FACES] = {
    // front
    { .a = 1, .b = 2, .c = 3 },
    { .a = 1, .b = 3, .c = 4 },
    // right
    { .a = 4, .b = 3, .c = 5 },
    { .a = 4, .b = 5, .c = 6 },
    // back
    { .a = 6, .b = 5, .c = 7 },
    { .a = 6, .b = 7, .c = 8 },
    // left
    { .a = 1, .b = 2, .c = 3 },
    { .a = 1, .b = 3, .c = 4 },
    // top
    { .a = 8, .b = 7, .c = 2 },
    { .a = 8, .b = 2, .c = 1 },
    // bottom
    { .a = 6, .b = 8, .c = 1 },
    { .a = 6, .b = 1, .c = 4 },
};

mesh_t mesh = {
    .vertices = NULL,
    .faces = NULL,
    .rotation = { 0, 0, 0}
};

void load_cube_mesh_data(void) {
    for (int i = 0; i < N_CUBE_VERTICES; i++) {
        vec3_t vertices = cube_vertices[i];
        array_push(mesh.vertices, vertices);
    }
    for (int i = 0; i < N_CUBE_FACES; i++) {
        face_t face = cube_faces[i];
        array_push(mesh.faces, face);
    }
}

void load_mesh_from_obj_file(const char* filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Error opening file");
        exit(EXIT_FAILURE);
    }
    char line[1024];
    while (fgets(line, sizeof(line), file)) {
        if (strncmp(line, "v ", 2) == 0) {
            vec3_t vertex;
            sscanf(line, "v %f %f %f", &vertex.x, &vertex.y, &vertex.z);
            array_push(mesh.vertices, vertex);
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
            array_push(mesh.faces, face);
        }
    }
    fclose(file);
}