const std = @import("std");
const fmt = std.fmt;

pub fn build(b: *std.build.Builder) void {
    const mainFileName = "mymodule";
    const src_dir = "src";
    const mainFilePath = fmt.comptimePrint("{s}/{s}.zig", .{ src_dir, mainFileName });
    const kernelFilePath = fmt.comptimePrint("{s}/{s}.zig", .{ src_dir, "kernel" });
    const main_tests = b.addTest(mainFilePath);
    const kernel_tests = b.addTest(kernelFilePath);
    kernel_tests.linkLibC();
    
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    test_step.dependOn(&kernel_tests.step);

    const obj = b.addObject(mainFileName, mainFilePath);
    obj.output_dir = src_dir;
    obj.setTarget(.{ .os_tag = .freestanding });

    const obj_step = b.step("obj", "Make debug object file");
    obj_step.dependOn(&obj.step);
}
