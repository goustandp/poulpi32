
OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv",
	      "elf32-littleriscv")
OUTPUT_ARCH(riscv)
STARTUP(build/startup.o)
MEMORY
{
    RAM (xrw)      : ORIGIN =0, LENGTH = 8K
}
_Min_Stack_Size = 0x100;
SECTIONS
{
  
  /* Read-only sections, merged into text segment: */
  . = 0x0;
  .dynsym         : { *(.dynsym) } > RAM
  .dynstr         : { *(.dynstr) } > RAM
  .plt            : { *(.plt) } > RAM
  .iplt           : { *(.iplt) } > RAM
  .text           :
  {
    *(.text .text.*) 
  } > RAM
  .rodata         : { *(.rodata .rodata.*) } > RAM
  .rodata1        : { *(.rodata1) } > RAM
  .sdata2         :
  {
    *(.sdata2 .sdata2.* .gnu.linkonce.s2.*)
  } > RAM
  .sbss2          : { *(.sbss2 .sbss2.* ) } > RAM

  /* Adjust the address for the data segment.  We want to adjust up to
     the same address within the page on the next page up.  */
  . = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));


  .dynamic        : { *(.dynamic) } > RAM
  . = DATA_SEGMENT_RELRO_END (0, .);
  .data           :
  {
    __DATA_BEGIN__ = .;
    *(.data .data.*)
  }
  .data1          : { *(.data1) } > RAM
  .got            : { *(.got.plt) *(.igot.plt) *(.got) *(.igot) } > RAM
  .sdata          :
  {
    __SDATA_BEGIN__ = .;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata .srodata.*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  } > RAM
  _edata = .; PROVIDE (edata = .);
  . = .;
  __bss_start = .;
  .sbss           :
  {
    *(.dynsbss)
    *(.sbss .sbss.*)
    *(.scommon)
  } > RAM
  .bss            :
  {
   *(.dynbss)
   *(.bss .bss.*)
   *(COMMON)
   /* Align here to ensure that the .bss section occupies space up to
      _end.  Align after .bss to ensure correct alignment even if the
      .bss section disappears because there are no input sections.
      FIXME: Why do we need it? When there is no .bss section, we do not
      pad the .data section.  */
   . = ALIGN(. != 0 ? 32 / 8 : 1);
  } > RAM
  . = ALIGN(32 / 8);
  . = SEGMENT_START("ldata-segment", .);
  . = ALIGN(32 / 8);
  __BSS_END__ = .;
    __global_pointer$ = MIN(__SDATA_BEGIN__ + 0x800,
		            MAX(__DATA_BEGIN__ + 0x800, __BSS_END__ - 0x800));
  _end = .; PROVIDE (end = .);
  . = DATA_SEGMENT_END (.);
  .stack : {
    . = ALIGN(4);
    . = . + _Min_Stack_Size;
   } > RAM
   PROVIDE(_stack_end = .);
  /* Stabs debugging sections.  */
  .line           0 : { *(.line) } > RAM
  /DISCARD/ : { *(.note.GNU-stack) *(.gnu_debuglink) *(.gnu.lto_*) }
}



