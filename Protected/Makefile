# The C and C++ rules are already setup by default.
# The only one that needs changing is the assembler 
# rule, as we use nasm instead of GNU as.

ASMSOURCES=entry.asm gdt.asm interrupt.asm
SOURCES=entry.o main.o monitor.o common.o descriptor_tables.o isr.o interrupt.o gdt.o
CFLAGS=-Wall -fomit-frame-pointer -nostdlib -nostdinc -fno-builtin -fno-stack-protector
LDFLAGS=-T link.ld
ASFLAGS=-f aout

all: clean $(SOURCES) link

clean:
	-rm *.o LOADER.BIN

link:
	ld $(LDFLAGS) -o LOADER.BIN $(SOURCES)

.asm.o:
	nasm $(ASFLAGS) $(ASMSOURCES)
