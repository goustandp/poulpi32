
OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv",
	      "elf32-littleriscv")
OUTPUT_ARCH(riscv)
STARTUP(build/startup.o)
MEMORY
{
    RAM (xrw)      : ORIGIN =0x100, LENGTH = 8K
}
_mem_base_addr = 0x0;
_stack_size = 0x100;
SECTIONS
{
  
  /* Read-only sections, merged into text segment: */
  . = _stack_size + _mem_base_addr;
  . = ALIGN(8);
  .text      (ALIGN(4))   : 
  { 
    *(.text) 
  } > RAM
  
  .rodata       (ALIGN(4))   : 
  { 
    *(.rodata .rodata.* .rodata1) 
    . = ALIGN(. != 0 ? 32 / 8 : 1);
  } > RAM

  . = ALIGN(8);
  .sbss2        (ALIGN(4))   : 
  { 
    *(.sbss2 .sbss2.* ) 
  } > RAM
  
  . = ALIGN(8);

  /* Adjust the address for the data segment.  We want to adjust up to
     the same address within the page on the next page up.  */
  . = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));

  .data         (ALIGN(4))   :
  {
    __DATA_BEGIN__ = .;
    *(.data .data.* .data1)
  }
  .data1        (ALIGN(4))   : { *(.data1) } > RAM
  .got          (ALIGN(4))   : { *(.got.plt) *(.igot.plt) *(.got) *(.igot) } > RAM
  .sdata        (ALIGN(4))   :
  {
    __SDATA_BEGIN__ = .;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata .srodata.*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
    *(.sdata2 .sdata2.* .gnu.linkonce.s2.*)
  } > RAM
  
  _edata = .; PROVIDE (edata = .);
  __bss_start = .;
  .sbss        (ALIGN(4))  :
  {
    *(.dynsbss)
    *(.sbss .sbss.*)
    *(.scommon)
  } > RAM
  
  .bss         (ALIGN(4))    :
  {
   *(.dynbss)
   *(.bss .bss.*)
   *(COMMON)
  . = ALIGN(. != 0 ? 32 / 8 : 1);
  } > RAM
  . = SEGMENT_START("ldata-segment", .);
  . = ALIGN(8);
  __BSS_END__ = .;

  _end = .; PROVIDE (end = .);
  . = DATA_SEGMENT_END (.);

}



