MRUBY_VERSION     ?= 3.4.0
MRUBY_REPO        ?= https://github.com/mruby/mruby
MRUBY_CONFIG_NAME ?= baremetal

TARGET_TRIPLET  = riscv64-unknown-elf
CROSS_COMPILE  ?= $(TARGET_TRIPLET)-
CC              = $(CROSS_COMPILE)gcc
PICOLIBC_SPECS ?= --specs=/usr/lib/picolibc/$(TARGET_TRIPLET)/picolibc.specs
OSLIB          ?= --oslib=semihost

# No linker flags, not stdlib, no crt*.o
CROSS_LDFLAGS ?= -nostdlib -nostartfiles

# No libc, no startfiles, no builtin functions, no exceptions
CFLAGS        += -ffreestanding
CFLAGS        += -fno-builtin
CFLAGS        += -fno-exceptions
CFLAGS        += -fno-stack-protector
# riscv64 hardware / instruction set
CFLAGS        += -march=rv64imac
CFLAGS        += -mabi=lp64
CFLAGS        += -mcmodel=medany
# Use picolibc to resolv mruby dependency on libc in freestanding environment
CFLAGS        += $(PICOLIBC_SPECS)
# Also add same warning flags and debug options as mruby
CFLAGS        += -g -Wall -Wundef -Werror-implicit-function-declaration
CFLAGS        += -Wwrite-strings

LIBMRUBY      ?= mruby/build/$(MRUBY_CONFIG_NAME)/lib/libmruby.a

hello.elf: hello.c riscv.ld test_program.c $(LIBMRUBY)
	$(CC) $(CFLAGS) $(OSLIB) -Imruby/include -Triscv.ld $< -o $@ $(LIBMRUBY)

import-mruby:
	egrep -q "^PROJECT_NUMBER\s*=\s*$(MRUBY_VERSION)\s*$$" mruby/Doxyfile >/dev/null 2>&1 \
		|| (git clone $(MRUBY_REPO) \
			&& cd mruby && git checkout -b release-$(MRUBY_VERSION) $(MRUBY_VERSION) && rm -rf .git)

@PHONY: mruby
mruby: import-mruby
	test -f $(LIBMRUBY) \
		|| (cd mruby && CONFIG=../build_config.rb \
				MRUBY_CONFIG_NAME=$(MRUBY_CONFIG_NAME) \
				CROSS_COMPILE=$(CROSS_COMPILE) \
				CROSS_CFLAGS="$(CFLAGS)" \
				CROSS_LDFLAGS="$(CROSS_LDFLAGS)" \
				rake)
$(LIBMRUBY): mruby

test_program.c: test_program.rb $(LIBMRUBY)
	mruby/bin/mrbc -Btest_symbol test_program.rb

QEMU ?= qemu-system-riscv64
QEMU_SEMIHOST ?= -semihosting-config enable=on
QEMU_HW_FLAGS ?= -serial none -nographic -machine virt,accel=tcg -cpu rv64
QEMU_FLAGS    ?= -monitor none -bios none $(QEMU_SEMIHOST) $(QEMU_HW_FLAGS)
run: hello.elf
	$(QEMU) $(QEMU_FLAGS) -kernel $<

clean:
	rm -rf hello.elf test_program.c

clean-mruby:
	rm -rf mruby/build/* *.rb.lock
