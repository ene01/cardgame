const std = @import("std");
const zeit = @import("zeit");

pub const LogType = enum(u8) {
    Info,
    Warn,
    Error,
};

pub fn log(src: std.builtin.SourceLocation, lvl: LogType, string: []const u8) !void {
    const alloc = std.heap.page_allocator;
    var env = try std.process.getEnvMap(alloc);
    defer env.deinit();

    const cwd = std.fs.cwd();
    const fname = "log.txt";

    var file = try cwd.createFile(fname, .{
        .truncate = false,
    });
    defer file.close();

    _ = try file.seekFromEnd(0);

    const now_time = try zeit.instant(.{});
    const local = try zeit.local(alloc, &env);
    const now_local = now_time.in(&local);
    const dt = now_local.time();

    const m_type = switch (lvl) {
        .Info => "INFO",
        .Warn => "WARN",
        .Error => "ERROR",
    };

    const origin = src.fn_name;

    const hour = dt.hour;
    const min = dt.minute;
    const sec = dt.second;

    const corrected_hour = if (dt.hour < 10) try std.fmt.allocPrint(alloc, "0{}", .{hour}) else try std.fmt.allocPrint(alloc, "{}", .{hour});
    const corrected_min = if (dt.minute < 10) try std.fmt.allocPrint(alloc, "0{}", .{min}) else try std.fmt.allocPrint(alloc, "{}", .{min});
    const corrected_sec = if (dt.second < 10) try std.fmt.allocPrint(alloc, "0{}", .{sec}) else try std.fmt.allocPrint(alloc, "{}", .{sec});

    const message = try std.fmt.allocPrint(alloc, "[{s}:{s}:{s}] [{s}] {s} | {s}\n", .{ corrected_hour, corrected_min, corrected_sec, m_type, origin, string });
    defer alloc.free(message);

    _ = try file.write(message);
}

test "logging" {
    try log(@src(), LogType.Info, "This is a test, if this doesn't' appear, i fucked up");
    try std.testing.expect(true);
}
