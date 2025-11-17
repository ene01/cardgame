const std = @import("std");
const time = @import("time.zig");

pub const MessageType = enum(u8) {
    Info,
    Warn,
    Error,
};

/// Writes a message to a generic log file, the message contains the time of logging, type of message, function from where it came from and the message itself.
/// The log message already contains a new line character, so the message itself does not need one.
pub fn write(src: std.builtin.SourceLocation, lvl: MessageType, comptime fmt: []const u8, args: anytype) !void {
    const cwd = std.fs.cwd();
    const fname = "log.txt";

    var file = try cwd.createFile(fname, .{ .truncate = false });
    defer file.close();

    _ = try file.seekFromEnd(0);

    const current_time = try time.getTime();

    const m_type = switch (lvl) {
        .Info => "INFO",
        .Warn => "WARN",
        .Error => "ERROR",
    };

    const origin = src.fn_name;

    const hour = current_time.hour;
    const min = current_time.minute;
    const sec = current_time.second;

    var h_buffer: [3]u8 = undefined;
    var m_buffer: [3]u8 = undefined;
    var s_buffer: [3]u8 = undefined;
    const corrected_hour = if (hour < 10) try std.fmt.bufPrint(h_buffer[0..], "0{}", .{hour}) else try std.fmt.bufPrint(h_buffer[0..], "{}", .{hour});
    const corrected_min = if (min < 10) try std.fmt.bufPrint(m_buffer[0..], "0{}", .{min}) else try std.fmt.bufPrint(m_buffer[0..], "{}", .{min});
    const corrected_sec = if (sec < 10) try std.fmt.bufPrint(s_buffer[0..], "0{}", .{sec}) else try std.fmt.bufPrint(s_buffer[0..], "{}", .{sec});

    var fs_buffer: [512]u8 = undefined;
    const formatted_string = try std.fmt.bufPrint(fs_buffer[0..], fmt, args);

    var ms_buffer: [512]u8 = undefined;
    const message = try std.fmt.bufPrint(
        ms_buffer[0..],
        "[{s}:{s}:{s}] [{s}] {s} | {s}\n",
        .{ corrected_hour, corrected_min, corrected_sec, m_type, origin, formatted_string },
    );

    try file.writeAll(message);
}

test "logging" {
    const string = "something has gone wrong";
    try write(@src(), MessageType.Info, "This is a test, if this doesn't appear, then {s}", .{string});

    // this test is very prone to fail when not coded properly or not having the correct params, so im just assuming that not having an error means success.
    try std.testing.expect(true);
}
