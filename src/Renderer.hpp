//
// Created by Paolo Broglio on 16/05/25.
//

#ifndef RENDERER_HPP
#define RENDERER_HPP

#include <vector>
#include <SDL2/SDL.h>

#include "ColorBuffer.hpp"
#include "Mesh.hpp"
#include "Triangle.hpp"
#include "Vec3.hpp"

#define FPS 30
#define FRAME_TARGET_TIME (1000 / FPS)

class Renderer {
private:
    SDL_Window *window;
    SDL_Renderer *renderer;
    ColorBuffer colorBuffer;
    SDL_Texture *colorBufferTexture;

    static constexpr int window_width = 800;
    static constexpr int window_height = 600;
    static constexpr int fov_factor = 640;
    Vec3 camera_position = Vec3(0.0f, 0.0f, -5.0f);

    bool isRunning;
    int previousFrameTime;

    std::vector<Triangle> trianglesToRender;

    Mesh mesh;

    void processInput();

    void update();

    void render_color_buffer();

    void render();

    void cleanup();

    static Vec2 project(Vec3 projectable);

public:
    Renderer();

    ~Renderer();

    void init();

    void run();
};


#endif //RENDERER_HPP
