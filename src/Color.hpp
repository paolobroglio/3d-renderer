#ifndef COLOR_HPP
#define COLOR_HPP

#include <cstdint>

enum class Color : uint32_t {
    Yellow = 0xFFFFFF00,
    Black = 0xFF000000,
    Green = 0xFF00FF00,
    Red = 0xFFFF0000,
    White = 0xFFFFFFFF,
    LightBlack = 0xFF333333
};


#endif