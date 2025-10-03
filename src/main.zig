const std = @import("std");
const Renderer = @import("renderer.zig").Renderer;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            std.log.err("[Renderer] GPA leak detected", .{});
        }
    }
    const allocator = gpa.allocator();

    var renderer = Renderer.init(allocator) catch |err| {
        std.log.err("[Renderer] Error initializing renderer: {}", .{err});
        return err;
    };
    defer renderer.deinit();

    renderer.run() catch |err| {
        std.log.err("[Renderer] Error running renderer: {}", .{err});
        return err;
    };
}
