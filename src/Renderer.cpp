//
// Created by Paolo Broglio on 16/05/25.
//

#include "Renderer.hpp"
#include <iostream>

void Renderer::processInput() {
}

void Renderer::update() {
}

void Renderer::render() {
}

void Renderer::cleanup() {
}

Renderer::Renderer() {
}

Renderer::~Renderer() {
}

void Renderer::init() {
    std::cout << "Initializing SDL" << std::endl;

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
       std::cerr << "Error initializing SDL" << std::endl;
        return false;
    }

    std::cout << "Initializing SDL Window" << std::endl;

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
