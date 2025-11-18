const std = @import("std");
pub const zeit = @import("zeit");

pub fn getTime() !zeit.Time {
    var buffer: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buffer[0..]);
    const alloc = fba.allocator();

    const now_time = try zeit.instant(.{});
    const local = try zeit.local(alloc, null);
    const now_local = now_time.in(&local);
    const dt = now_local.time();

    return dt;
}
