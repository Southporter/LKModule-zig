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
    obj.addSystemIncludePath(.{ .cwd_relative = "/usr/include" });
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

    const obj_c = b.addObject(.{
        .name = "zig_c_module",
        .target = b.resolveTargetQuery(.{
            .os_tag = .freestanding,
        }),
        // .target = .{ .os_tag = .freestanding },
        .optimize = .ReleaseSmall,
        .root_source_file = b.path("src/zigmodule_with_c.zig"),
        .code_model = .kernel,
        .strip = true,
    });
    obj_c.linkLibC();
    obj_c.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/include" });
    obj_c.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include" });
    obj_c.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include/uapi" });
    obj_c.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include/generated" });
    obj_c.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include/generated/uapi" });
    obj_c.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/include/uapi" });
    obj_c.bundle_compiler_rt = false;
    obj_c.export_table = false;

    const c_artifact = b.addInstallArtifact(obj_c, .{
        .dest_dir = .{
            .override = .{
                .custom = "obj",
            },
        },
    });
    b.getInstallStep().dependOn(&c_artifact.step);
}
