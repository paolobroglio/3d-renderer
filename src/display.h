#ifndef DISPLAY_H
#define DISPLAY_H

#include <SDL2/SDL.h>
#include <stdbool.h>
#include <stdint.h>

#define FPS 30
#define FRAME_TARGET_TIME (1000 / FPS)

extern int window_width;
extern int window_height;

extern SDL_Window* window;
extern SDL_Renderer* renderer;
extern uint32_t* color_buffer;
extern SDL_Texture* color_buffer_texture;

bool initialize_window(void);
void set_color_in_buffer(int buffer_index, uint32_t color);
void draw_pixel(int x, int y, uint32_t color);
void draw_rect(int x, int y, int width, int height, uint32_t color);
void draw_grid(void);
void render_color_buffer(void);
void destroy_window(void);
void clear_color_buffer(uint32_t clear_color);

#endif