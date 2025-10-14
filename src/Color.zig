pub const Color = enum(u32) {
    Yellow = 0xFF00FFFF,
    Black = 0xFF000000,
    Green = 0xFF00FF00,
    Red = 0xFF0000FF,
    White = 0xFFFFFFFF,
    LightGrey = 0xFF333333,
    _,

    pub fn fromU32(value: u32) Color {
        return @enumFromInt(value);
    }
};
