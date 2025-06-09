//
// Created by Paolo Broglio on 17/05/25.
//

#ifndef COLORBUFFER_HPP
#define COLORBUFFER_HPP
#include <cstdint>

#include "Color.hpp"


class ColorBuffer {
private:
    int maxY, maxX;

    void setColorInBuffer(int i, Color color) const;
    void fillFlatBottomTriangle(int x0, int y0, int x1, int y1, int x2, int y2, Color color);
    void fillFlatTopTriangle(int x0, int y0, int x1, int y1, int x2, int y2, Color color);

public:
    uint32_t *buffer;

    ColorBuffer(int width, int height);

    ~ColorBuffer();

    void drawPixel(int x, int y, Color color) const;

    void clear(Color color) const;

    void drawGrid() const;

    void drawRect(int x, int y, int w, int h, Color color) const;

    void drawLine(int x0, int y0, int x1, int y1, Color color) const;

    void drawTriangle(int x0, int y0, int x1, int y1, int x2, int y2, Color color) const;

    void drawFilledTriangle(int x0, int y0, int x1, int y1, int x2, int y2, Color color);
};


#endif //COLORBUFFER_HPP
