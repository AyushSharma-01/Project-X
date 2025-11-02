#define VGA_ADDRESS 0xB8000
#define WHITE_ON_RED 0x4F

void kmain(void)
{   
    const char text[] = "Kernel initialized at 0x8000";
    char *vga = (char*)(VGA_ADDRESS + 160); // Start at second row

    for (int i = 0; text[i] != '\0'; i++)
    {
        vga[i * 2]     = text[i];       // Character
        vga[i * 2 + 1] = WHITE_ON_RED;  // Attribute byte
    }

    while(1) 
    {
        __asm__ __volatile__("hlt");
    }
}
