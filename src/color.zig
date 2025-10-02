pub const Color = enum(u32) {
    Yellow = 0xFF00FFFF, // Memory: [FF, FF, 00, FF] = R, G, B, A
    Black = 0xFF000000, // Memory: [00, 00, 00, FF]
    Green = 0xFF00FF00, // Memory: [00, FF, 00, FF]
    Red = 0xFF0000FF, // Memory: [FF, 00, 00, FF]
    White = 0xFFFFFFFF, // Memory: [FF, FF, FF, FF]
    LightGrey = 0xFF333333, // Memory: [33, 33, 33, FF]
};
