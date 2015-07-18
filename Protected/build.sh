clear
nasm -f aout entry.asm
nasm -f aout gdtidt.asm
nasm -f aout interrupt.asm
gcc -c -fomit-frame-pointer -fno-builtin-function -nostdlib -nostdinc -fno-builtin -fno-stack-protector main.c monitor.c common.c descriptor_tables.c isr.c timer.c keyboard.c
ld -T link.ld -o LOADER.BIN entry.o main.o monitor.o common.o descriptor_tables.o isr.o interrupt.o gdtidt.o timer.o keyboard.o
