ENTRY(kmain)

SECTIONS
{
    /* Physical memory address where the kernel is loaded */
    . = 0x00100000;

    /* --- Text/code section --- */
    .text ALIGN(4K) : {
        _kernel_start = .;
        *(.text*)
    }

    /* --- Read-only data --- */
    .rodata ALIGN(4K) : {
        *(.rodata*)
    }

    /* --- Initialized data --- */
    .data ALIGN(4K) : {
        *(.data*)
    }

    /* --- Uninitialized data (BSS) --- */
    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss*)
    }

    /* --- Kernel end symbols --- */
    _kernel_end = .;
    _kernel_size = _kernel_end - _kernel_start;
}
