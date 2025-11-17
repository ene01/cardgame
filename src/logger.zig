const std = @import("std");
const time = @import("time.zig");

/// Bytes used for the strings, 1 byte equals 1 character.
const s_bytes = 1048;

pub const MessageType = enum(u8) {
    Info,
    Warn,
    Error,
};

/// Writes and creates a message to a named log file, the message contains the time of logging, type of message, function from where it came from and the message itself.
/// The log message already contains a new line character, so the message itself does not need one.
/// If the file already exists, then it will just keep writting bellow the existing text.
pub fn writeTo(name: []const u8, src: std.builtin.SourceLocation, lvl: MessageType, comptime fmt: []const u8, args: anytype) !void {
    const current_time = try time.getTime();

    const hour = current_time.hour;
    const min = current_time.minute;
    const sec = current_time.second;

    var h_buffer: [3]u8 = undefined;
    var m_buffer: [3]u8 = undefined;
    var s_buffer: [3]u8 = undefined;
    const corrected_hour = if (hour < 10) try std.fmt.bufPrint(h_buffer[0..], "0{}", .{hour}) else try std.fmt.bufPrint(h_buffer[0..], "{}", .{hour});
    const corrected_min = if (min < 10) try std.fmt.bufPrint(m_buffer[0..], "0{}", .{min}) else try std.fmt.bufPrint(m_buffer[0..], "{}", .{min});
    const corrected_sec = if (sec < 10) try std.fmt.bufPrint(s_buffer[0..], "0{}", .{sec}) else try std.fmt.bufPrint(s_buffer[0..], "{}", .{sec});

    const m_type = switch (lvl) {
        .Info => "INFO",
        .Warn => "WARN",
        .Error => "ERROR",
    };

    const origin = src.fn_name;

    var fs_buffer: [s_bytes]u8 = undefined;
    const formatted_string = try std.fmt.bufPrint(fs_buffer[0..], fmt, args);

    var ms_buffer: [s_bytes]u8 = undefined;
    const message = try std.fmt.bufPrint(
        ms_buffer[0..],
        "[{s}:{s}:{s}] [{s}] {s} | {s}\n",
        .{ corrected_hour, corrected_min, corrected_sec, m_type, origin, formatted_string },
    );

    try simpleWrite(name, "{s}", .{message});
}

/// Writes and creates a message to a generic log file, the message contains the time of logging, type of message, function from where it came from and the message itself.
/// The log message already contains a new line character, so the message itself does not need one.
/// If the file already exists, then it will just keep writting bellow the existing text.
pub fn write(src: std.builtin.SourceLocation, lvl: MessageType, comptime fmt: []const u8, args: anytype) !void {
    try writeTo("log.txt", src, lvl, fmt, args);
}

/// Writes a simple message file, the log will only contain the message given.
/// The log message already contains a new line character, so the message itself does not need one.
/// If the file already exists, then it will just keep writting bellow the existing text.
pub fn simpleWrite(name: []const u8, comptime fmt: []const u8, args: anytype) !void {
    const cwd = std.fs.cwd();

    var file = try cwd.createFile(name, .{ .truncate = false });
    defer file.close();

    _ = try file.seekFromEnd(0);

    var fs_buffer: [s_bytes]u8 = undefined;
    const formatted_string = try std.fmt.bufPrint(fs_buffer[0..], fmt, args);

    try file.writeAll(formatted_string);
}

test "logging" {
    const string = "something has gone wrong";
    try writeTo("test.txt", @src(), MessageType.Info, "This is a test, if this doesn't appear, then {s}", .{string});
    try write(@src(), MessageType.Info, "This is also a test, you better be reading this, because if not, then {s}", .{string});
    try simpleWrite("simple.txt", "Simple test, if not being read, then {s}", .{string});

    // this test is very prone to fail when not coded properly or not having the correct params, so im just assuming that not having an error means success.
    try std.testing.expect(true);
}
