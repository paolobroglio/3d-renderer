//
// Created by Paolo Broglio on 08/05/25.
//

#ifndef TRIANGLE_H
#define TRIANGLE_H
#include "vector.h"

typedef struct {
    int a;
    int b;
    int c;
} face_t;

typedef struct {
    vec2_t points[3];
} triangle_t;


#endif //TRIANGLE_H
