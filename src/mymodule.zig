const std = @import("std");
const builtin = @import("builtin");

// Switch based on tag, as using target / mode is trickier
// without full std lib access.
const print = (if (builtin.os.tag == .freestanding) @import("kernel.zig") else @import("debug.zig"))
    .print;

export fn init_hellokernel() callconv(.C) c_int {
    print("{s}\n", .{"Hello kernel!"});
    return 0;
}

export fn exit_hellokernel() callconv(.C) void {
    print("{s}\n", .{"Goodbye kernel!"});
}

test "test1" {
    print("{s}\n", .{"Hello stdout \"kernel\"!"});
}
