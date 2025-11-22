CC             = riscv64-unknown-elf-gcc
LIBC          ?= --specs=/usr/lib/picolibc/riscv64-unknown-elf/picolibc.specs
OSLIB         ?= --oslib=semihost
MACHDEP_FLAGS ?= -mcmodel=medany -march=rv64imac -mabi=lp64
CFLAGS        ?= $(LIBC) $(OSLIB) $(MACHDEP_FLAGS)

hello.elf: hello.c riscv.ld
	$(CC) $(CFLAGS) -Triscv.ld $< -o $@

QEMU ?= qemu-system-riscv64
QEMU_SEMIHOST ?= -semihosting-config enable=on
QEMU_HW_FLAGS ?= -serial none -nographic -machine virt,accel=tcg -cpu rv64
QEMU_FLAGS    ?= -monitor none -bios none $(QEMU_SEMIHOST) $(QEMU_HW_FLAGS)
run: hello.elf
	$(QEMU) $(QEMU_FLAGS) -kernel hello.elf

clean:
	rm -rf hello.elf
