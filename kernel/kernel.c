// kernel.c
#include <stdint.h>

#define VGA_ADDRESS 0xB8000
#define WHITE_ON_BLACK 0x0F

void kmain(void) {
    char *video = (char*) VGA_ADDRESS;

    const char *msg = "Kernel initialized successfully!";
    for (int i = 0; msg[i] != '\0'; i++) {
        video[i * 2] = msg[i];           // character
        video[i * 2 + 1] = WHITE_ON_BLACK; // attribute byte
    }

    // Loop forever so QEMU doesn't immediately quit
    for(;;);
}
