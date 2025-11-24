//! Simple file-based logger with timestamped messages.

const std = @import("std");
const time = @import("time.zig");

const bytes = 2048;
const default_filename = [7]u8{ 'l', 'o', 'g', '.', 't', 'x', 't' };

/// Appends formatted text to a file without truncating it.
fn writeSimple(filename: []const u8, comptime fmt: []const u8, args: anytype) void {
    var file = std.fs.cwd().createFile(filename, .{ .truncate = false }) catch |e| {
        std.log.err("logger failed to create file '{s}': {s}", .{ filename, @errorName(e) });
        return;
    };
    defer file.close();

    _ = file.seekFromEnd(0) catch |e| {
        std.log.err("logger failed to seek in '{s}': {s}", .{ filename, @errorName(e) });
        return;
    };

    var buffer: [bytes]u8 = undefined;
    const msg = safeFmtOrFallback(buffer[0..], "", fmt, args);

    file.writeAll(msg) catch |e| {
        std.log.err("logger failed to write to '{s}': {s}", .{ filename, @errorName(e) });
        return;
    };
}

/// Writes a full log entry with timestamp, module name, and function.
fn writeLog(filename: []const u8, src: std.builtin.SourceLocation, logtype: []const u8, comptime msg: []const u8, args: anytype) void {
    const current_time = time.getTime() catch time.zeit.Time{};

    if (current_time.year == 1970) {
        std.log.err("logger time failed, message will still be written but time is disabled.", .{});
    }

    const h_fallback = [2]u8{ 'H', 'H' };
    const m_fallback = [2]u8{ 'M', 'M' };
    const s_fallback = [2]u8{ 'S', 'S' };
    const ms_fallback = [3]u8{ 's', 's', 's' };

    var h_buf: [2]u8 = undefined;
    var m_buf: [2]u8 = undefined;
    var s_buf: [2]u8 = undefined;
    var ms_buf: [3]u8 = undefined;

    const corrected_h = twoDigitPaddedInt(h_buf[0..], h_fallback[0..], current_time.hour);
    const corrected_m = twoDigitPaddedInt(m_buf[0..], m_fallback[0..], current_time.minute);
    const corrected_s = twoDigitPaddedInt(s_buf[0..], s_fallback[0..], current_time.second);
    const corrected_ms = threeDigitPaddedInt(ms_buf[0..], ms_fallback[0..], current_time.millisecond);

    var fmt_buf: [bytes]u8 = undefined;
    const inner_msg = safeFmtOrFallback(fmt_buf[0..], "", msg, args);

    // remove trailing ".zig"
    const mod_name = src.file[0 .. src.file.len - 4];
    const mod_func = src.fn_name;

    var msg_buf: [bytes]u8 = undefined;
    const full_msg = safeFmtOrFallback(
        msg_buf[0..],
        "",
        "[{s}] [{s}:{s}:{s}.{s}] [{s}/{s}] {s}\n",
        .{ logtype, corrected_h, corrected_m, corrected_s, corrected_ms, mod_name, mod_func, inner_msg },
    );

    writeSimple(filename, "{s}", .{full_msg});
}

/// Logs an info-level message.
pub fn info(src: std.builtin.SourceLocation, comptime fmt: []const u8, args: anytype) void {
    writeLog(default_filename[0..], src, "INFO", fmt, args);
}

/// Logs a warning.
pub fn warn(src: std.builtin.SourceLocation, comptime fmt: []const u8, args: anytype) void {
    writeLog(default_filename[0..], src, "WARN", fmt, args);
}

/// Logs a critical message.
pub fn crit(src: std.builtin.SourceLocation, comptime fmt: []const u8, args: anytype) void {
    writeLog(default_filename[0..], src, "CRIT", fmt, args);
}

/// Formats into a buffer; falls back on error.
fn safeFmtOrFallback(buf: []u8, fallback: []const u8, comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.bufPrint(buf, fmt, args) catch |e| {
        std.log.err("logger fmt failed '{s}': {s}", .{ fmt, @errorName(e) });
        return fallback;
    };
}

/// Produces a zero-padded 2-digit integer.
fn twoDigitPaddedInt(buf: []u8, comptime fallback: []const u8, value: u6) []const u8 {
    if (value < 10) {
        return safeFmtOrFallback(buf, fallback, "0{}", .{value});
    } else {
        return safeFmtOrFallback(buf, fallback, "{}", .{value});
    }
}

/// Produces a zero-padded 3-digit integer.
fn threeDigitPaddedInt(buf: []u8, comptime fallback: []const u8, value: u10) []const u8 {
    if (value < 10) {
        return safeFmtOrFallback(buf, fallback, "00{}", .{value});
    } else if (value > 10 and value < 100) {
        return safeFmtOrFallback(buf, fallback, "0{}", .{value});
    } else {
        return safeFmtOrFallback(buf, fallback, "{}", .{value});
    }
}
