#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <SDL2/SDL.h>
#include "display.h"
#include "vector.h"
#include "color.h"

#define N_POINTS 9*9*9
#define FOV_FACTOR 640

vec3_t cube_points[N_POINTS];
vec2_t projected_cube_points[N_POINTS];

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

  int index = 0;
  for(float x = -1.0; x <= 1.0; x += 0.25) {
    for (float y = -1.0; y <= 1.0; y += 0.25) {
      for (float z = -1.0; z <= 1.0; z += 0.25) {
        vec3_t new_point = { .x = x, .y = y, .z = z};
        cube_points[index++] = new_point;
      }
    }
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

  for (int i = 0; i < N_POINTS; i++) {
    vec3_t point = cube_points[i];

    vec3_t transformed = vec3_rotate_x(point, cube_rotation.x);
    transformed = vec3_rotate_y(transformed, cube_rotation.y);
    transformed = vec3_rotate_z(transformed, cube_rotation.z);

    transformed.z -= camera_position.z;

    vec2_t projected_point = project(transformed);

    projected_cube_points[i] = projected_point;
  }
}

void render(void) {

  draw_grid();
  
  for (int i = 0; i < N_POINTS; i++) {
    vec2_t projected_point = projected_cube_points[i];
    draw_rect(
      projected_point.x + (window_width / 2), 
      projected_point.y + (window_height / 2), 
      4, 
      4, 
      YELLOW);
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
