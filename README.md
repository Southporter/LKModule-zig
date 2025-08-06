## Linux Kernel Module on Zig

Build linux kernel module with zig.

## TODO

- More tests.

## Requires

- Zig v0.14.0 or later.
- You need kernel headers and gcc toolchain (with build-essential [debian] or base-devel [archlinux]).

## Build with:
```bash
zig build
```
Object file will be in `zig-out/lib/zigmodule.o`.

