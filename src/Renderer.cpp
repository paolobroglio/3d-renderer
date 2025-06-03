//
// Created by Paolo Broglio on 16/05/25.
//

#include "Renderer.hpp"
#include "Color.hpp"
#include <iostream>

void Renderer::processInput() {
    SDL_Event event;
    SDL_PollEvent(&event);

    switch (event.type) {
        case SDL_QUIT:
            isRunning = false;
            break;
        case SDL_KEYDOWN:
            if (event.key.keysym.sym == SDLK_ESCAPE)
                isRunning = false;
            break;
    }
}

void Renderer::update() {
    int elapsed_time = SDL_GetTicks() - previousFrameTime;
    int time_to_wait = FRAME_TARGET_TIME - elapsed_time;

    if (time_to_wait > 0) {
        SDL_Delay(time_to_wait);
    }

    previousFrameTime = SDL_GetTicks();

    trianglesToRender.clear();

    // mesh.rotation.x += 0.01;
    // mesh.rotation.y += 0.00;
    // mesh.rotation.z += 0.00;
    auto meshRotation = mesh.getRotation();
    mesh.setRotation(Vec3(meshRotation.getX() + 0.01, meshRotation.getY() + 0.00, meshRotation.getZ() + 0.00));

    auto meshFaces = mesh.getFaces();

    for (auto meshFace: meshFaces) {
        auto vertices = mesh.getVertices();
        Vec3 face_vertices[3];
        face_vertices[0] = vertices.at(meshFace.a - 1);
        face_vertices[1] = vertices.at(meshFace.b - 1);
        face_vertices[2] = vertices.at(meshFace.c - 1);

        Vec3 transformed_vertices[3];

        for (int j = 0; j < 3; j++) {
            Vec3 vertex = face_vertices[j];
            Vec3 transformed_vertex = vertex.rotateX(mesh.getRotation().getX());
            transformed_vertex = transformed_vertex.rotateY(mesh.getRotation().getY());
            transformed_vertex = transformed_vertex.rotateZ(mesh.getRotation().getZ());
            transformed_vertex.setZ(transformed_vertex.getZ() + 5);
            transformed_vertices[j] = transformed_vertex;
        }

        // todo: backface culling

        Vec3 vectorA = transformed_vertices[0]; /*   A    */
        Vec3 vectorB = transformed_vertices[1]; /*  / \   */
        Vec3 vectorC = transformed_vertices[2]; /* C---B  */

        Vec3 vectorAB = vectorB - vectorA;
        Vec3 vectorAC = vectorC - vectorA;

        vectorAB.normalize();
        vectorAC.normalize();

        Vec3 faceNormal = vectorAB.cross(vectorAC);

        faceNormal.normalize();

        Vec3 cameraRay = camera_position - vectorA;

        float dot = cameraRay.dot(faceNormal);
        if (dot < 0.0)
            continue;

        Triangle projected_triangle;

        for (int j = 0; j < 3; j++) {
            Vec2 projected_vertex = project(transformed_vertices[j]);
            projected_vertex.setX(projected_vertex.getX() + window_width / 2);
            projected_vertex.setY(projected_vertex.getY() + window_height / 2);
            projected_triangle.setVertex(j, projected_vertex);
        }
        trianglesToRender.push_back(projected_triangle);
    }
}

void Renderer::render_color_buffer() {
    SDL_UpdateTexture(
        colorBufferTexture,
        NULL,
        colorBuffer.buffer,
        (int) (window_width * sizeof(uint32_t))
    );
    SDL_RenderCopy(renderer, colorBufferTexture, NULL, NULL);
}

void Renderer::render() {
    colorBuffer.drawGrid();

    for (auto triangle: trianglesToRender) {
        colorBuffer.drawRect(
            triangle.getVertex(0).getX(),
            triangle.getVertex(0).getY(),
            3,
            3,
            RED);
        colorBuffer.drawRect(
            triangle.getVertex(1).getX(),
            triangle.getVertex(1).getY(),
            3,
            3,
            RED);
        colorBuffer.drawRect(
            triangle.getVertex(2).getX(),
            triangle.getVertex(2).getY(),
            3,
            3,
            RED);

        colorBuffer.drawTriangle(
            triangle.getVertex(0).getX(),
            triangle.getVertex(0).getY(),
            triangle.getVertex(1).getX(),
            triangle.getVertex(1).getY(),
            triangle.getVertex(2).getX(),
            triangle.getVertex(2).getY(),
            YELLOW
        );
    }

    trianglesToRender.clear();

    render_color_buffer();
    colorBuffer.clear(BLACK);

    SDL_RenderPresent(renderer);
}

void Renderer::cleanup() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

Vec2 Renderer::project(Vec3 projectable) {
    Vec2 projected_point = Vec2(
        (fov_factor * projectable.getX()) / projectable.getZ(),
        (fov_factor * projectable.getY()) / projectable.getZ()
    );
    return projected_point;
}

Renderer::Renderer() : colorBuffer(window_width, window_height) {
}

Renderer::~Renderer() {
}

void Renderer::init() {
    std::cout << "Initializing SDL" << std::endl;

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) {
        std::cerr << "Error initializing SDL" << std::endl;
        return;
    }

    std::cout << "Initializing SDL_Window" << std::endl;

    window = SDL_CreateWindow(
        "3D Renderer",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        window_width,
        window_height,
        SDL_WINDOW_BORDERLESS
    );

    if (!window) {
        std::cerr << "Error creating SDL_Window." << std::endl;
        return;
    }

    std::cout << "Initializing SDL_Renderer" << std::endl;

    renderer = SDL_CreateRenderer(window, -1, 0);

    if (!renderer) {
        std::cerr << "Error creating SDL_Renderer." << std::endl;
        return;
    }

    std::cout << "Done initializing SDL_Renderer" << std::endl;

    std::cout << "Initializing Color Buffer Texture" << std::endl;

    colorBufferTexture = SDL_CreateTexture(
        renderer,
        SDL_PIXELFORMAT_RGB888,
        SDL_TEXTUREACCESS_STREAMING,
        window_width,
        window_height
    );

    if (colorBufferTexture == NULL) {
        fprintf(stderr, "Color buffer texture creaton failed\n");
        return;
    }

    std::cout << "Done initializing Color Buffer Texture" << std::endl;

    std::cout << "Done initializing SDL" << std::endl;

    mesh = Mesh::loadOBJ("resources/meshes/f22.obj");

    isRunning = true;
}

void Renderer::run() {
    while (isRunning) {
        processInput();
        update();
        render();
    }
    cleanup();
}
