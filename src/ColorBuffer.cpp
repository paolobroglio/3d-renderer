//
// Created by Paolo Broglio on 17/05/25.
//

#include "ColorBuffer.hpp"

#include <iostream>
#include <tgmath.h>

void ColorBuffer::setColorInBuffer(const int i, const uint32_t color) {
    buffer[i] = color;
}

ColorBuffer::ColorBuffer(int width, int height) : maxX(width), maxY(height) {
    buffer = static_cast<uint32_t *>(malloc(sizeof(uint32_t) * width * height));
    if (buffer == NULL) {
        fprintf(stderr, "Color buffer allocation failed\n");
        return;
    }
}

ColorBuffer::~ColorBuffer() {
    free(buffer);
}

void ColorBuffer::drawPixel(int x, int y, uint32_t color) {
    if (x >= 0 && x < maxX && y >= 0 && y < maxY) {
        setColorInBuffer(maxX * y + x, color);
    }
}

void ColorBuffer::clear(const uint32_t color) {
    for (int y = 0; y < maxY; y++) {
        for (int x = 0; x < maxX; x++) {
            setColorInBuffer(y * maxX + x, color);
        }
    }
}

void ColorBuffer::drawGrid() {
    uint32_t color = 0xFF333333;
    for (int y = 0; y < maxY; y += 10) {
        for (int x = 0; x < maxX; x += 10) {
            setColorInBuffer(y * maxX + x, color);
        }
    }
}

void ColorBuffer::drawRect(const int x, const int y, const int w, const int h, const uint32_t color) {
    for (int i = 0; i < w; i++) {
        for (int j = 0; j < h; j++) {
            int current_x = x + i;
            int current_y = y + j;
            drawPixel(current_x, current_y, color);
        }
    }
}

void ColorBuffer::drawLine(const int x0, const int y0, const int x1, const int y1, const uint32_t color) {
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
                               const uint32_t color) {
    drawLine(x0, y0, x1, y1, color);
    drawLine(x1, y1, x2, y2, color);
    drawLine(x2, y2, x0, y0, color);
}
