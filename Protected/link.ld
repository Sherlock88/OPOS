OUTPUT_FORMAT("binary")
ENTRY(entry)
phys = 0x0500;
SECTIONS
{
  .text phys : AT(phys) {
    code = .;
    *(.text)	
    
  }
  .data : AT(phys + (data - code))
  {
    data = .;
    *(.data)
    *(.rodata)	    
  }
  .bss : AT(phys + (bss - code))
  {
    bss = .;
    *(.bss)
    
  }
  end = .;
}


