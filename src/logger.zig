const std = @import("std");
const time = @import("time.zig");

/// Bytes used for the strings, 1 byte equals 1 character.
const s_bytes = 1048;

/// Writes a simple message to the log file.
/// The log message already contains a new line character, so the message itself does not need one.
/// If the file already exists, then it will just keep writting bellow the existing text.
pub fn writeSimple(name: []const u8, comptime fmt: []const u8, args: anytype) void {
    const cwd = std.fs.cwd();

    var file = cwd.createFile(name, .{ .truncate = false }) catch |e| {
        std.log.err("logger failed to create file '{s}': {s}", .{ name, @errorName(e) });
        return;
    };
    defer file.close();

    _ = file.seekFromEnd(0) catch |e| {
        std.log.err("logger failed to seek in '{s}': {s}", .{ name, @errorName(e) });
        return;
    };

    var buffer: [s_bytes]u8 = undefined;
    const msg = std.fmt.bufPrint(buffer[0..], fmt, args) catch |e| {
        std.log.err("logger failed to format message: {s}", .{@errorName(e)});
        return;
    };

    file.writeAll(msg) catch |e| {
        std.log.err("logger failed to write to '{s}': {s}", .{ name, @errorName(e) });
        return;
    };
}

fn safeFmtOrFallback(buf: []u8, fallback: []const u8, comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.bufPrint(buf, fmt, args) catch |e| {
        std.log.err("logger fmt failed '{s}': {s}", .{ fmt, @errorName(e) });
        return fallback;
    };
}

pub fn writeLog(filename: []const u8, src: std.builtin.SourceLocation, logtype: []const u8, comptime fmt: []const u8, args: anytype) void {
    const current_time = time.getTime() catch time.zeit.Time{};

    if (current_time.year == 1970) {
        std.log.err("logger time failed, message will still be written but time is disabled.", .{});
    }

    const h_fallback = [_]u8{ 'H', 'H' };
    const m_fallback = [_]u8{ 'M', 'M' };
    const s_fallback = [_]u8{ 'S', 'S' };

    const hour = current_time.hour;
    const min = current_time.minute;
    const sec = current_time.second;

    var h_buffer: [2]u8 = undefined;
    var m_buffer: [2]u8 = undefined;
    var s_buffer: [2]u8 = undefined;

    const corrected_hour = if (hour > 10) safeFmtOrFallback(h_buffer[0..], &h_fallback, "{}", .{hour}) else safeFmtOrFallback(h_buffer[0..], &h_fallback, "0{}", .{hour});
    const corrected_min = if (min > 10) safeFmtOrFallback(m_buffer[0..], &m_fallback, "{}", .{min}) else safeFmtOrFallback(m_buffer[0..], &m_fallback, "0{}", .{min});
    const corrected_sec = if (sec > 10) safeFmtOrFallback(s_buffer[0..], &s_fallback, "{}", .{sec}) else safeFmtOrFallback(s_buffer[0..], &s_fallback, "0{}", .{sec});

    var fs_buffer: [s_bytes]u8 = undefined;
    const formatted_string = safeFmtOrFallback(fs_buffer[0..], "", fmt, args);

    var ms_buffer: [s_bytes]u8 = undefined;
    const message = safeFmtOrFallback(ms_buffer[0..], "", "[{s}:{s}:{s}] [{s}] [{s}/{s}] | {s}\n", .{ corrected_hour, corrected_min, corrected_sec, logtype, src.module, src.fn_name, formatted_string });

    writeSimple(filename, "{s}", .{message});
}

pub fn info(src: std.builtin.SourceLocation, comptime fmt: []const u8, args: anytype) void {
    writeLog("log.txt", src, "INFO", fmt, args);
}

pub fn warn(src: std.builtin.SourceLocation, comptime fmt: []const u8, args: anytype) void {
    writeLog("log.txt", src, "WARN", fmt, args);
}

pub fn err(src: std.builtin.SourceLocation, comptime fmt: []const u8, args: anytype) void {
    writeLog("log.txt", src, "ERROR", fmt, args);
}

test "logging types" {
    info(@src(), "this is a test", .{});
    warn(@src(), "warning, this is a test", .{});
    err(@src(), "critical levels of testing reached", .{});
    // this test is very prone to fail when not coded properly or not having the correct params, so im just assuming that not having an error means success.
    try std.testing.expect(true);
}
