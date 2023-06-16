const std = @import("std");
const fmt = std.fmt;

pub fn build(b: *std.Build) void {
    const mainFileName = "zigmodule";
    const src_dir = "src";
    const mainFilePath = fmt.comptimePrint("{s}/{s}.zig", .{
        src_dir,
        mainFileName,
    });
    const kernelFilePath = fmt.comptimePrint("{s}/{s}.zig", .{
        src_dir,
        "kernel",
    });
    const main_tests = b.addTest(.{
        .root_source_file = .{
            .path = mainFilePath,
        },
    });
    const kernel_tests = b.addTest(.{
        .root_source_file = .{
            .path = kernelFilePath,
        },
    });
    kernel_tests.linkLibC();

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    test_step.dependOn(&kernel_tests.step);

    const obj = b.addObject(.{
        .name = mainFileName,
        .target = .{ .os_tag = .freestanding },
        .optimize = .ReleaseSmall,
        .root_source_file = .{
            .path = mainFilePath,
        },
    });
    obj.addSystemIncludePath("include");
    obj.bundle_compiler_rt = false;
    obj.code_model = .kernel;
    obj.export_table = false;
    obj.disable_stack_probing = false;
    obj.disable_sanitize_c = false;
    obj.strip = true;
    obj.override_dest_dir = .{ .custom = "obj" };
    b.installArtifact(obj);
}
