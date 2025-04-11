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

void set_color_in_buffer(uint32_t color, int buffer_index) {
  color_buffer[buffer_index] = color;
}

void clear_color_buffer(uint32_t clear_color) {
  for (int y = 0; y < window_height; y++) {
    for (int x = 0; x < window_width; x++) {
      set_color_in_buffer(clear_color, y*window_width + x);
    }
  }
}

void draw_rect(int x, int y, int width, int height, uint32_t color) {
  int h = y + height;
  int w = x + width;
  for (int y0 = y; y0 < h; y0++){
    for (int x0 = x; x0 < w; x0++) {
      int cb_index = y0 * window_width + x0;
      set_color_in_buffer(color, cb_index);
    }
  }
}

void draw_grid(void) {
  uint32_t color = 0xFF333333;
  for (int y = 0; y < window_height; y+=10) {
    for (int x = 0; x < window_width; x+=10) {
      set_color_in_buffer(color, y*window_width + x);
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