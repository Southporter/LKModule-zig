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
    obj.addIncludePath(b.path("include"));
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

    const kernel_src = b.addTranslateC(.{
        .root_source_file = b.path("src/headers.h"),
        .target = b.resolveTargetQuery(.{
            .os_tag = .freestanding,
        }),
        .optimize = .ReleaseSmall,
        .link_libc = true,
    });

    // Change these paths to match your kernel source tree
    kernel_src.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/include" });
    kernel_src.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include" });
    kernel_src.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include/uapi" });
    kernel_src.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include/generated" });
    kernel_src.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/arch/x86/include/generated/uapi" });
    kernel_src.addSystemIncludePath(.{ .cwd_relative = "/usr/src/kernels/6.15.9-201.fc42.x86_64/include/uapi" });

    const kernel_mod = kernel_src.createModule();

    const c_mod = b.createModule(.{
        .root_source_file = b.path("src/zigmodule_with_c.zig"),
        .target = b.resolveTargetQuery(.{
            .os_tag = .freestanding,
        }),
        .optimize = .ReleaseSmall,
        .code_model = .kernel,
    });
    c_mod.addImport("kernel", kernel_mod);

    const obj_c = b.addObject(.{
        .name = "zig_c_module",
        .code_model = .kernel,
        .root_module = c_mod,
        .strip = true,
    });
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
