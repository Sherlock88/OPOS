// main.c -- Defines the C-code kernel entry point, calls initialisation routines.
//           Made for JamesM's tutorials <www.jamesmolloy.co.uk>

#include "monitor.h"

int main()
{
    init_shell();
	asm volatile("int $0x3");
    asm volatile("int $0x4");
	asm volatile("sti");
	//u16int i=5/0;
    //init_timer(1);
    return 0;
}
