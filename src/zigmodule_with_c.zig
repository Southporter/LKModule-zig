const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("linux/kernel.h");
    @cInclude("linux/kern_levels.h");
});

export fn init_hellokernel() c_int {
    c.printk(c.KERN_INFO ++ "Hello kernel!\n");
    return 0;
}

export fn exit_hellokernel() void {
    c.printk(c.KERN_INFO ++ "Goodbye kernel!\n");
}

test "test1" {
    _ = c.printk("\n{s}\n", .{"Hello stdout \"kernel\"!"});
}
