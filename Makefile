KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)
SOURCE := src
# The zig main file name
ZIGMODULE := mymodule
MODULENAME := $(ZIGMODULE)

obj-m := $(MODULENAME).o
$(MODULENAME)-y := $(SOURCE)/ffi.o
$(MODULENAME)-y += $(SOURCE)/$(ZIGMODULE).o
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
	zig build obj \
	&& touch $(PWD)/$(SOURCE)/.$(ZIGMODULE).o.cmd