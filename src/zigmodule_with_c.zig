const std = @import("std");
const builtin = @import("builtin");
const kernel = @import("kernel");

export fn init_hellokernel() c_int {
    kernel.printk(kernel.KERN_INFO ++ "Hello kernel!\n");
    return 0;
}

export fn exit_hellokernel() void {
    kernel.printk(kernel.KERN_INFO ++ "Goodbye kernel!\n");
}

test "test1" {
    _ = kernel.printk("\n{s}\n", .{"Hello stdout \"kernel\"!"});
}
