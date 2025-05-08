#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <SDL2/SDL.h>
#include "display.h"
#include "vector.h"
#include "color.h"
#include "mesh.h"

#define FOV_FACTOR 640

triangle_t triangles_to_render[N_MESH_FACES];

vec3_t camera_position = { .x = 0, .y = 0, .z = -5};
vec3_t cube_rotation = { .x = 0, .y = 0, .z = 0};

bool is_running = false;

int previous_frame_time = 0;

int setup(void) {
  color_buffer = (uint32_t*) malloc(sizeof(uint32_t) * window_width * window_height);
  if (color_buffer == NULL) {
    fprintf(stderr, "Color buffer allocation failed\n");
    return 1;
  }

  color_buffer_texture = SDL_CreateTexture(
    renderer, 
    SDL_PIXELFORMAT_RGB888, 
    SDL_TEXTUREACCESS_STREAMING, 
    window_width, 
    window_height
  );

  if (color_buffer_texture == NULL){
    fprintf(stderr, "Color buffer texture creaton failed\n");
    return 1;
  }

  return 0;
}

void process_input(void) {
  SDL_Event event;
  SDL_PollEvent(&event);

  switch (event.type) {
    case SDL_QUIT:
      is_running = false;
      break;
    case SDL_KEYDOWN:
      if (event.key.keysym.sym == SDLK_ESCAPE)
        is_running = false;
      break;
  }
}

vec2_t project(vec3_t point) {
  vec2_t projected_point = {
    .x = (FOV_FACTOR * point.x) / point.z,
    .y = (FOV_FACTOR * point.y) / point.z
  };
  return projected_point;
}

void update(void) {

  int elapsed_time = SDL_GetTicks() - previous_frame_time;
  int time_to_wait = FRAME_TARGET_TIME - elapsed_time;

  if (time_to_wait > 0) {
      SDL_Delay(time_to_wait);
  }

  previous_frame_time = SDL_GetTicks();

  cube_rotation.y += 0.01;
  cube_rotation.x += 0.01;
  cube_rotation.z += 0.01;

  for (int i = 0; i < N_MESH_FACES; i++) {
    face_t mesh_face = mesh_faces[i];
    vec3_t face_vertices[3];
    face_vertices[0] = mesh_vertices[mesh_face.a - 1];
    face_vertices[1] = mesh_vertices[mesh_face.b - 1];
    face_vertices[2] = mesh_vertices[mesh_face.c - 1];

    triangle_t projected_triangle;

    for (int j = 0; j < 3; j++) {
      vec3_t vertex = face_vertices[j];
      vec3_t transformed_vertex = vec3_rotate_x(vertex, cube_rotation.x);
      transformed_vertex = vec3_rotate_y(transformed_vertex, cube_rotation.y);
      transformed_vertex = vec3_rotate_z(transformed_vertex, cube_rotation.z);

      transformed_vertex.z -= camera_position.z;

      vec2_t projected_vertex = project(transformed_vertex);

      projected_vertex.x += window_width / 2;
      projected_vertex.y += window_height / 2;

      projected_triangle.points[j] = projected_vertex;
    }
    triangles_to_render[i] = projected_triangle;
  }
}

void render(void) {

  draw_grid();
  
  for (int i = 0; i < N_MESH_FACES; i++) {
    triangle_t triangle = triangles_to_render[i];
    draw_rect(
      triangle.points[0].x,
      triangle.points[0].y,
      3,
      3,
      YELLOW);
    draw_rect(
      triangle.points[1].x,
      triangle.points[1].y,
      3,
      3,
      YELLOW);
    draw_rect(
      triangle.points[2].x,
      triangle.points[2].y,
      3,
      3,
      YELLOW);

    draw_triangle(
      triangle.points[0].x,
      triangle.points[0].y,
      triangle.points[1].x,
      triangle.points[1].y,
      triangle.points[2].x,
      triangle.points[2].y,
      YELLOW
    );
  }

  render_color_buffer();
  clear_color_buffer(BLACK);

  SDL_RenderPresent(renderer);
}

int main(int argc, char const *argv[])
{
  is_running = initialize_window();

  int setup_result = setup();
  if (setup_result != 0) {
    return setup_result;
  }

  while(is_running){
    process_input();
    update();
    render();
  }

  destroy_window();

  return 0;
}
