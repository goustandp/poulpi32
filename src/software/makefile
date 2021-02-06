CC=riscv32-unknown-elf-gcc
OBJDUMP=riscv32-unknown-elf-objdump
OBJCOPY=riscv32-unknown-elf-objcopy
LDSCRIPT = ./firmware/poulpi32.ld
BUILDDIR = ./build
FIRMDIR = ./firmware
PROJDIR = ./project_sources

$(BUILDDIR)/startup.o: $(FIRMDIR)/startup.S
	$(CC) -c $(FIRMDIR)/startup.S -o $(BUILDDIR)/startup.o

$(BUILDDIR)/test.o: $(PROJDIR)/test.c
	$(CC) -c $(PROJDIR)/test.c -o $(BUILDDIR)/test.o

$(BUILDDIR)/a.out: $(BUILDDIR)/test.o $(BUILDDIR)/startup.o
	$(CC) -nostartfiles -Wl,-T -Wl,$(LDSCRIPT) $(BUILDDIR)/test.o -o $(BUILDDIR)/a.out 

all: $(BUILDDIR)/a.out
	$(OBJCOPY) -S -O binary $(BUILDDIR)/a.out mem.bin 

clean:
	rm -f $(BUILDDIR)/*.o $(BUILDDIR)/*.out mem.bin

dump: $(BUILDDIR)/a.out
	$(OBJDUMP) -S -D $(BUILDDIR)/a.out
