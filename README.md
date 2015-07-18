## OPOS - Open Source Operating System

### Abstract

Operating System is a software, in a nutshell, programs and data that provides an interface between the hardware and other software. The OS is responsible for management and coordination of processes and allocation and sharing of hardware resources such as RAM and disk space, and acts as a host for computing applications running on the OS. An Operating System may also provide orderly accesses to the hardware by competing software routines.

OPOS or Open Source Operating System is an effort to realize how an Operating System works. OPOS is basically a light-weight & small scale Operating System that provides 32-bit, Protected mode, CUI (Character User Interface) targeted towards Intel Pentium processors. This Operating System, as of now has got a terminal which supports few commands in Real mode. This system can be booted from any FAT-12 or FAT-16 formatted media and also from Compact Disc. As it boots into Protected mode, driver for keyboard and monitor is added with it. Code for Programmable Timer Controller has also been incorporated to respond to processor clock pulses.

----------

### Requirements

- ##### Hardware Requirements

  1. Processor - Any Pentium/Celeron/8086 compatible processor
  2. Memory - No mentionable requirement
  3. Monitor - Preferably color - monitor for built-in graphics
  4. Floppy Disk - 1.44 MB, 31/2  inch,  high-density (HD)    
  5. Floppy Disk Drive
  6. USB Disk (Pen Drive)
  7. Compact Disc (CD) 
  8. Compact Disk Drive

- ##### Software Requirements
 
  1. Assembler - nasm (Netwide Assembler) v2.07 (For Windows XP)
  2. Compiler - gcc v4.3.2
  3. Linker - ld v2.17
  4. GNU Make
  5. Simulation Software - VMware Workstation v6.5, Sun Virtual Box v3.0.2 , Bochs, Portable Sun Virtual Box v3.0.2, 8086 Emulator, Virtual Floppy Disk
  6. Disk Editing Software - Diamond CS Boot Sector Explorer, Sectedit, Winhex, Ntdiskview, PTEDIT32
  7. Editor - Notepad++ v4.2.2

----------

### FEATURES

The Open Source Operating System has the following features:

- ##### Real mode features:

  - Boots in 16-bit real mode
  - CUI (Character User Interface) shell

- ##### Protected mode features:

  - Boots in 32-bit Protected mode
  - CUI (Character User Interface) shell
  - A Keyboard driver 
  - A Monitor Driver 
  - Responds to PIT (Programmable Interval Timer) pulses
  - Boots from FAT-12/16 formatted media and CD in El-Torito emulation mode
  - Kernel is only around 12 KB
 
----------

### Building Blocks


OPOS is a 32-bit Protected mode/ 16-bit Real mode CUI (Character User Interface) Operating System targeted towards Intel Pentium processors. 

- Boot Loader
- Shell
- Memory Management Routines
- Interrupt Handlers
- Monitor Driver
- Keyboard Driver
- Programmable Interval Timer


##### Boot Loader

----------

OPOS uses a minimalistic boot loader to boot itself which occupies the first sector of the Volume Boot Record (VBR) itself. It does not have its own Master Boot Record (MBR) code, thereby it has to rely on other other standard MBRs to load its VBR. Its compatible with Windows XP & GRUB MBRs. Others are not tested yet. Since x86 family of processors initialize in Real mode, OPOS loader is written in NASM 16 bit assembly language. Boot loader is loaded at 0000:7C00 on system startup. To ease the task of debugging & maintainance, a modular approach has been adopted. The sections present in the boot loader are as follows:

1.	START
2.	LOAD_ROOT
3.	LOAD_FAT
4.	LOAD_IMAGE
5.	DisplayMessage
6.	ReadSectors
7.	ClusterLBA
8.	LBACHS

`START` defines the entry point of the boot loader which begins after skipping the initial BPB (Bios Parameter Block) area. A stack is set up at the highest addressable memory area & an initial welcome message is displayed.

`LOAD_ROOT` module locates the root directory area of FAT16/FAT32 filesystem, computes its length & copies the portion to memory starting at `7C00:0200`, above the boot code. Thereafter, the entries in the root directory are iterated one by one searching for the boot image entry. If a match is found, control jumps to `LOAD_FAT` routine, else displays an error message.

`LOAD_FAT` takes care of  loading the FAT from a FAT formatted filesystem. It extracts the first cluster of the boot image from the root directory entry, calculates beginning sector & size of FAT & copies the entire file allocation table at `7C00:0200` for FAT12 loader & at `17C0:0200` for FAT16 loader.

`LOAD_IMAGE` module handles the loading of boot image to the memory. For FAT12 , the image is loaded at `0050:0100` while in case of FAT16, it is loaded at `37C0:0100`. It iterates in a loop, follows the FAT cluster chain, converts the clusters to equivalent number of sectors & reads them into memory. For FAT16, it handles odd & even clusters differently while in case of FAT 32, both of them are handled in the same way. It continues in the loop until it finds `0x0FF0`, FAT EOF (End Of File) marker.

`DisplayMessage` is a simple wrapper around BIOS Teletype function (`0x10, AH = 0x0E`) to display ASCII string starting at `DS:SI`. It is used to output boot loader messages.

`ReadSectors` is responsible for reading sectors represented in CHS (Cylinder-Head-Sector) format. It makes use of BIOS interrupt `0x13, AH = 0x02` for Fat12 boot loader & `0x13, AH = 0x42` for FAT16 loader internally. The routine also has error handler code. On success, it displays it reports a progress message to the user.

`ClusterLBA` is a subsidiary routine which calculates LBA (Logical Block Addressing) address of the first sector of a given cluster has been mapped to.

`LBACHS` module computes the LBA type sector address to its equivalent CHS type sector address. This conversion is needed as some BIOS interrupt understands only CHS format sector address.

After the executable BIOS code is over, the remaining bytes of the boot loader are NULL filled till 510<sup>th</sup> byte. Last two bytes are appended with `0x55AA` magic signature which makes standard BIOSes recognize this code to be an executable code. Otherwise, the OS may not boot on most of the systems.

                        
##### Shell

----------

Real mode version of OPOS has got a Shell or the user interface which is primitive & uses a Character User Interface. OPOS shell support basic commands *e.g.*:

- `clear` - To clear the entire screen
- `help` - To display the command details
- `hello` - To display “Hello World” in green color
- `shutdown` - To turn off the system
- `reboot` - To reboot the system

OPOS Protected mode version drops the user to a CUI shell, then triggers some interrupt and handles them accordingly.


##### Memory Management Routines

----------

As x86 processors initializes in Real mode & continues to stay in that mode if no explicit change is done in memory configuration, OPOS does not need to do anything special while operating in Real mode.

On the contrary, Protected mode may only be entered after the system software sets up several descriptor tables and enables the Protection Enable (PE) bit in the Control Register 0 (CR0). Before entering into Protected mode, a minimal GDT containing just three entries, *viz.* Null segment descriptor, Code segment descriptor & Data segment descriptor, is set up. Then the GDTR register is flushed by setting appropriate base & limit value. The 21<sup>st</sup> address line (A20 line) also must be enabled to allow the use of all the address lines so that the CPU can access beyond 1 megabyte of memory (only the first 20 are allowed to be used after power-up to guarantee compatibility with older software). After performing those two steps, the PE bit must be set in the CR0 register and a far jump must be made to clear the pre-fetch input queue.


##### Interrupt Handlers

----------

Immediately after setting up GDT, IDT is also built up. First 32 interrupts (0 – 31) are raised internally by the processor. If these remain unmapped, processor will triple fault & reset. Similarly, 16 available IRQs are generated by external hardwares. Having them mapped & non-null is essential. Therefore, those are remapped to ISR 32 – 47 by OPOS. After those ISRs and IRQs are defined, IDT descriptors are initialized by the addresses of corresponding handlers & proper privilege bits. OPOS categorizes ISRs on the basis of pushing of error codes on the stack. Interrupts 8 & 10 – 14 pushes an error code onto the stack. The others do not. OPOS has these two types of ISR stubs & a generic IRQ stub written in assembly. These serve as the entry point of actual handlers written in C. Stubs mainly handle pushing & popping of registers to save & retrieve data from previous context & also dispatch control to respective ISRs & IRQs. To maintain consistency in operation, for those ISRs where interrupt does not push any error code, a dummy error code is pushed by the stub. 


##### Monitor Driver

----------

Since the design goal of OPOS has never been to produce high end graphics but to be a simple CLI, its monitor driver is pretty simple & exposes a bare minimum set of API. The monitor driver includes functions to move cursor from one location to another depending on the parameters passed, to scroll up the entire while it’s filled up with text, to output ASCII string, decimal & hexadecimal numbers. Its output is 80*25 characters wide, which is internally mapped to a frame buffer starting at linear address `0xB8000.`

Real mode version of OPOS makes use of BIOS interrupt `0x10` & its various teletype sub functions. In Protected mode, it directly writes to specified memory address & then sends certain bit patterns to VGA registers to update screen output.


##### Keyboard Driver

----------

Handling keyboard input in Real mode kernel of OPOS is easier & the nasty stuff is mostly managed by the BIOS. All it does to retrieve the ASCII code & scan code of the pressed key is to call BIOS function `0x16, AH = 0`. Pressing of keyboard keys triggers IRQ1, which gets mapped to ISR 33 according to the scheme explained above in “Interrupt Handlers” section. During the initialization of keyboard driver, it binds a custom keyboard handler function with ISR33. There is already a key map defined within the keyboard driver. When a key is pressed & the control is transferred to the keyboard handler, it checks the status of keys like CTRL, SHIFT, and CAPS LOCK etc. to determine key combinations. The keyboard input is buffered in a linear array of size 255 characters. Beyond that, the buffer will overflow & subsequent key presses are lost.


##### Programmable Interval Timer

----------

PIT delivers clock pulses at a custom frequency & raises IRQ0. According to the scheme described above, IRQ0 is remapped to ISR 32 in OPOS. During initialization, frequency is set by sending calculated bit patterns to data register `0x40` & command register `0x43`. A timer callback function is associated with IRQ0 so that when a timer interrupt occurs, the control gets automatically transferred to the handler method. The callback function in OPOS does not do much apart from printing a message to the console informing the user about the event that interrupt has occurred.




