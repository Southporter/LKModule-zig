const std = @import("std");
const fmt = std.fmt;

pub fn build(b: *std.Build) void {
    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/zigmodule.zig"),
    });
    const kernel_tests = b.addTest(.{
        .root_source_file = b.path("src/kernel.zig"),
    });
    kernel_tests.linkLibC();

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
    test_step.dependOn(&kernel_tests.step);

    const obj = b.addObject(.{
        .name = "zigmodule",
        .target = b.resolveTargetQuery(.{
            .os_tag = .freestanding,
        }),
        // .target = .{ .os_tag = .freestanding },
        .optimize = .ReleaseSmall,
        .root_source_file = b.path("src/zigmodule.zig"),
        .code_model = .kernel,
        .strip = true,
    });
    obj.addSystemIncludePath(b.path("include"));
    obj.bundle_compiler_rt = false;
    obj.export_table = false;
    // obj.disable_stack_probing = false;
    // obj.disable_sanitize_c = false;
    // obj.override_dest_dir = .{ .custom = "obj" };
    const artifact = b.addInstallArtifact(obj, .{
        .dest_dir = .{
            .override = .{
                .custom = "obj",
            },
        },
    });
    b.getInstallStep().dependOn(&artifact.step);
}
