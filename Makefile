KERNELRELEASE=$(shell uname -r)
KERNELDIR ?= /lib/modules/$(KERNELRELEASE)/build
PWD := $(shell pwd)
SOURCE := src
OBJ := zig-out/obj
# The zig main file name
ZIGMODULE := zigmodule
MODULENAME := $(ZIGMODULE)

obj-m := $(MODULENAME).o
$(MODULENAME)-y := $(SOURCE)/ffi.o
$(MODULENAME)-y += $(OBJ)/$(ZIGMODULE).o
ccflags-y += -I$(src)/include

default: zig.o
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules

install:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules_install

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
	rm -rf zig-cache src/zig-cache

# In case this isn't auto generated, make an empty .cmd file
# See: https://github.com/dynup/kpatch/issues/1125
zig.o:
	zig build \
	&& touch $(PWD)/$(OBJ)/.$(ZIGMODULE).o.cmd
