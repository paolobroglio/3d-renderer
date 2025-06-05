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
    enum class RenderMode : uint32_t {
        None = 0,
        Wireframe = 1 << 0,
        Vertices = 1 << 1,
        FilledFaces = 1 << 2,
        BackfaceCulling = 1 << 3,
    };

    SDL_Window *window;
    SDL_Renderer *renderer;
    ColorBuffer colorBuffer;
    SDL_Texture *colorBufferTexture;

    static constexpr int window_width = 800;
    static constexpr int window_height = 600;
    static constexpr int fov_factor = 640;
    Vec3 camera_position = Vec3(0.0f, 0.0f, 0.0f);

    RenderMode render_mode;
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

    void toggleRenderMode(const RenderMode& renderMode);

    friend RenderMode operator|(RenderMode a, RenderMode b) {
        return static_cast<RenderMode>(static_cast<uint32_t>(a) | static_cast<uint32_t>(b));
    }

    friend RenderMode operator&(RenderMode a, RenderMode b) {
        return static_cast<RenderMode>(static_cast<uint32_t>(a) & static_cast<uint32_t>(b));
    }

    friend RenderMode operator^(RenderMode a, RenderMode b) {
        return static_cast<RenderMode>(static_cast<uint32_t>(a) ^ static_cast<uint32_t>(b));
    }

    friend RenderMode& operator|=(RenderMode& a, RenderMode b) {
        a = a | b;
        return a;
    }

    friend RenderMode& operator^=(RenderMode& a, RenderMode b) {
        a = a ^ b;
        return a;
    }

    static bool hasFlag(RenderMode value, RenderMode flag) {
        return (static_cast<uint32_t>(value) & static_cast<uint32_t>(flag)) != 0;
    }

public:
    Renderer();

    ~Renderer();

    void init();

    void run();
};


#endif //RENDERER_HPP
