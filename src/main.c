#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <SDL2/SDL.h>
#include "display.h"

bool is_running = false;

int black = 0xFF000000;
int yellow = 0xFFFFFF00;


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

void update(void) {

}

void render(void) {
  SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
  SDL_RenderClear(renderer);

  draw_grid();

  draw_rect(10, 10, 100, 100, yellow);
  
  render_color_buffer();
  clear_color_buffer(black);


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
