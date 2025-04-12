#include "display.h"

int window_width = 800;
int window_height = 600;

SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
uint32_t* color_buffer = NULL;
SDL_Texture* color_buffer_texture = NULL;

bool initialize_window(void) {

  fprintf(stdout, "Initializing SDL \n");

  if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
    fprintf(stderr, "Error initializing SDL \n");
    return false;
  }

  fprintf(stdout, "Initializing SDL Window \n");

  window = SDL_CreateWindow(
    "3D Renderer", 
    SDL_WINDOWPOS_CENTERED, 
    SDL_WINDOWPOS_CENTERED, 
    window_width, 
    window_height, 
    SDL_WINDOW_BORDERLESS
  );

  if (!window) {
    fprintf(stderr, "Error creating SDL window. \n");
    return false;
  }

  fprintf(stdout, "Initializing SDL Renderer \n");

  renderer = SDL_CreateRenderer(window, -1, 0);

  if (!renderer) {
    fprintf(stderr, "Error creating SDL renderer. \n");
    return false;
  }

  fprintf(stdout, "Done initializing SDL \n");

  return true;
}

void set_color_in_buffer(int buffer_index, uint32_t color) {
  color_buffer[buffer_index] = color;
}

void clear_color_buffer(uint32_t clear_color) {
  for (int y = 0; y < window_height; y++) {
    for (int x = 0; x < window_width; x++) {
      set_color_in_buffer(y*window_width + x, clear_color);
    }
  }
}

void draw_pixel(int x, int y, uint32_t color) {
  if (x >= 0 && x < window_width && y >= 0 && y < window_height){
    set_color_in_buffer(window_width*y + x, color);
  }
}

void draw_rect(int x, int y, int width, int height, uint32_t color) {
  for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
          int current_x = x + i;
          int current_y = y + j;
          draw_pixel(current_x, current_y, color);
      }
  }
}

void draw_grid(void) {
  uint32_t color = 0xFF333333;
  for (int y = 0; y < window_height; y+=10) {
    for (int x = 0; x < window_width; x+=10) {
      set_color_in_buffer(y*window_width + x, color);
    }
  } 
}

void render_color_buffer(void) {
  SDL_UpdateTexture(
    color_buffer_texture, 
    NULL, 
    color_buffer,
    (int)(window_width * sizeof(uint32_t))
  );
  SDL_RenderCopy(renderer, color_buffer_texture, NULL, NULL);
}

void destroy_window(void) {
  free(color_buffer);

  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();
}