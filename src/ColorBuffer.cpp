//
// Created by Paolo Broglio on 17/05/25.
//

#include "ColorBuffer.hpp"

#include <iostream>

#include "Color.hpp"

void ColorBuffer::setColorInBuffer(const int i, const Color color) const {
    auto raw_color = static_cast<uint32_t>(color);
    buffer[i] = raw_color;
}

void ColorBuffer::fillFlatBottomTriangle(const int x0, const int y0, const int x1, const int y1, const int x2, const int y2, const Color color) {
    // m' = dX / dY inverse of the slope
    auto slope1 = static_cast<float>(x1 - x0) / (y1 - y0);
    auto slope2 = static_cast<float>(x2 - x0) / (y2 - y0);

    float x_start = x0;
    float x_end = x0;

    for (int y = y0; y <= y2; y++) {
        drawLine(x_start, y, x_end, y, color);

        x_start += slope1;
        x_end += slope2;
    }
}

void ColorBuffer::fillFlatTopTriangle(const int x0, const int y0, const int x1, const int y1, const int x2, const int y2, const Color color) {
    auto slope1 = static_cast<float>(x2 - x0) / (y2 - y0);
    auto slope2 = static_cast<float>(x2 - x1) / (y2 - y1);

    float x_start = x2;
    float x_end = x2;

    for (int y = y2; y >= y0; y--) {
        drawLine(x_start, y, x_end, y, color);

        x_start -= slope1;
        x_end -= slope2;
    }
}

ColorBuffer::ColorBuffer(const int width, const int height) : maxX(width), maxY(height) {
    buffer = static_cast<uint32_t *>(malloc(sizeof(uint32_t) * width * height));
    if (buffer == NULL) {
        fprintf(stderr, "Color buffer allocation failed\n");
        return;
    }
}

ColorBuffer::~ColorBuffer() {
    free(buffer);
}

void ColorBuffer::drawPixel(const int x, const int y, const Color color) const {
    if (x >= 0 && x < maxX && y >= 0 && y < maxY) {
        setColorInBuffer(maxX * y + x, color);
    }
}

void ColorBuffer::clear(const Color color) const {
    for (int y = 0; y < maxY; y++) {
        for (int x = 0; x < maxX; x++) {
            setColorInBuffer(y * maxX + x, color);
        }
    }
}

void ColorBuffer::drawGrid() const {
    for (int y = 0; y < maxY; y += 10) {
        for (int x = 0; x < maxX; x += 10) {
            setColorInBuffer(y * maxX + x, Color::LightBlack);
        }
    }
}

void ColorBuffer::drawRect(const int x, const int y, const int w, const int h, const Color color) const {
    for (int i = 0; i < w; i++) {
        for (int j = 0; j < h; j++) {
            int current_x = x + i;
            int current_y = y + j;
            drawPixel(current_x, current_y, color);
        }
    }
}

void ColorBuffer::drawLine(const int x0, const int y0, const int x1, const int y1, const Color color) const {
    int dx = x1 - x0;
    int dy = y1 - y0;

    int step = (abs(dx) > abs(dy)) ? abs(dx) : abs(dy);

    float x_step = dx / (float) step;
    float y_step = dy / (float) step;

    float current_x = x0;
    float current_y = y0;

    for (int i = 0; i < step; i++) {
        drawPixel(round(current_x), round(current_y), color);
        current_x += x_step;
        current_y += y_step;
    }
}

void ColorBuffer::drawTriangle(const int x0, const int y0, const int x1, const int y1, const int x2, const int y2,
                               const Color color) const {
    drawLine(x0, y0, x1, y1, color);
    drawLine(x1, y1, x2, y2, color);
    drawLine(x2, y2, x0, y0, color);
}

void ColorBuffer::drawFilledTriangle(int x0, int y0, int x1, int y1, int x2, int y2, const Color color) {
    // TODO: try a more efficient algorithm
    if (y0 > y1) {
        std::swap(y0, y1);
        std::swap(x0, x1);
    }
    if (y1 > y2) {
        std::swap(y1, y2);
        std::swap(x1, x2);
    }
    if (y0 > y1) {
        std::swap(y0, y1);
        std::swap(x0, x1);
    }

    if (y1 == y2) {
        fillFlatBottomTriangle(x0, y0, x1, y1, x2, y2, color);
    } else if (y0 == y1) {
        fillFlatTopTriangle(x0, y0, x1, y1, x2, y2, color);
    } else {
        // Compute M(x,y)
        auto My = y1;
        auto Mx = (static_cast<float>((x2 - x0) * (y1 - y0)) / static_cast<float>(y2 - y0)) + x0;

        // Fill flat bottom triangle
        fillFlatBottomTriangle(x0, y0, x1, y1, Mx, My, color);
        // Fill flat top triangle
        fillFlatTopTriangle(x1, y1, Mx, My, x2, y2, color);
    }
}
