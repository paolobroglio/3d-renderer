//
// Created by Paolo Broglio on 16/05/25.
//

#ifndef RENDERER_HPP
#define RENDERER_HPP

#include <vector>
#include <SDL2/SDL.h>

#include "Triangle.hpp"
#include "Vec3.hpp"

class Renderer {
private:
    SDL_Window *window;
    SDL_Renderer *renderer;
    unsigned long int *color_buffer;
    SDL_Texture *color_buffer_texture;

    static constexpr int window_width = 800;
    static constexpr int window_height = 600;
    static constexpr int fov_factor = 640;
    static constexpr Vec3 camera_position = Vec3(0.0f, 0.0f, -5.0f);

    bool isRunning;
    int previousFrameTime;

    std::vector<Triangle> trianglesToRender;


    void processInput();

    void update();

    void render();

    void cleanup();

public:
    Renderer();

    ~Renderer();

    void init();
};


#endif //RENDERER_HPP
