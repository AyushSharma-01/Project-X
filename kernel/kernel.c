#define VGA_ADDRESS 0xB80A0

void kmain(void) {
    char *vga = (char*)VGA_ADDRESS;
    vga[0] = 'K';           // Character
    vga[1] = 0x4f;          // Attribute byte
    while (1) {
        // Halt the CPU to prevent it from running off
        __asm__ __volatile__("hlt");
    }
}