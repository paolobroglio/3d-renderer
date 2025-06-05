//
// Created by Paolo Broglio on 17/05/25.
//

#ifndef COLORBUFFER_HPP
#define COLORBUFFER_HPP
#include <cstdint>


class ColorBuffer {
private:
    int maxY, maxX;

    void setColorInBuffer(int i, uint32_t color) const;
    void fillFlatBottomTriangle(int x0, int y0, int x1, int y1, int x2, int y2, uint32_t color);
    void fillFlatTopTriangle(int x0, int y0, int x1, int y1, int x2, int y2, uint32_t color);

public:
    uint32_t *buffer;

    ColorBuffer(int width, int height);

    ~ColorBuffer();

    void drawPixel(int x, int y, uint32_t color);

    void clear(uint32_t color);

    void drawGrid();

    void drawRect(int x, int y, int w, int h, uint32_t color);

    void drawLine(int x0, int y0, int x1, int y1, uint32_t color);

    void drawTriangle(int x0, int y0, int x1, int y1, int x2, int y2, uint32_t color);

    void drawFilledTriangle(int x0, int y0, int x1, int y1, int x2, int y2, uint32_t color);
};


#endif //COLORBUFFER_HPP
