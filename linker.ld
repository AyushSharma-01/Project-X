ENTRY(kmain)

SECTIONS
{
    /* Where your kernel is loaded by the bootloader */
    . = 0x8000;

    /* --- Code section --- */
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

    /* --- Uninitialized data --- */
    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss*)
    }

    /* --- Stack (no load, reserved space) --- */
    .stack (NOLOAD) : ALIGN(16) {
    _stack_bottom = .;
    . += 0x4000;         /* Reserve 16 KB */
    _stack_top = 0x7BFF;
}

    /* --- Kernel end symbols --- */
    _kernel_end = .;
    _kernel_size = _kernel_end - _kernel_start;
}
