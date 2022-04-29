const std = @import("std");

extern fn printk([*c]const u8) void;

fn writeFn(context: void, bytes: []const u8) error{}!usize {
    printk(@ptrCast([*c]const u8, bytes));
    _ = context;
    return bytes.len;
    // printk(&bytes);
}
const kWriter: std.io.Writer(void, error{}, writeFn) = undefined;

/// Formats the argument, then calls printk.
pub fn print(comptime fmt: []const u8, args: anytype) void {
    std.fmt.format(kWriter, fmt, args) catch unreachable;
}

const printf = std.c.printf;
const addNullByte = std.cstr.addNullByte;
const allocator = std.testing.allocator;

fn testPrint(v: void, str: []const u8) error{OutOfMemory}!usize {
    _ = v;
    const cstr = try addNullByte(allocator, str);
    allocator.free(cstr);
    const len_or_err = printf("%*", &cstr);
    return if (len_or_err < 0) error.C else @intCast(usize, len_or_err);
}

test "writeFn" {
    const testWriter: std.io.Writer(void, error{OutOfMemory}, testPrint) = undefined;

    try std.fmt.format(testWriter, "{s}\n", .{"test"});
}
