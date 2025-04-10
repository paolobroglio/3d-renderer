#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <SDL2/SDL.h>

int window_width = 800;
int window_height = 600;

SDL_Window* window = NULL;
SDL_Renderer* renderer = NULL;
bool is_running = false;

uint32_t* color_buffer = NULL;
SDL_Texture* color_buffer_texture = NULL;

int black = 0xFF000000;
int yellow = 0xFFFFFF00;

bool initialize_window(void) {

  fprintf(stdout, "Initializing SDL \n");

  if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
    fprintf(stderr, "Error initializing SDL \n");
    return false;
  }

  fprintf(stdout, "Initializing SDL Window \n");

  //SDL_DisplayMode display_mode;
  //SDL_GetCurrentDisplayMode(0, &display_mode);

  //window_width = display_mode.w;
  //window_height = display_mode.h;

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

  // SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);

  return true;
}

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

void render(void) {
  SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
  SDL_RenderClear(renderer);

  draw_grid();

  draw_rect(10, 10, 100, 100, yellow);
  
  render_color_buffer();
  clear_color_buffer(black);


  SDL_RenderPresent(renderer);
}

void destroy_window(void) {
  free(color_buffer);

  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();
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
