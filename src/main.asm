org 0x7C00
bits 16

%DEFINE ENDL 0x0D, 0x0A

start:
    jmp main

puts:
    ;saving registers
    push si
    push ax

.loop
    lodsb                   ; Load byte at DS:SI into AL and increment SI
    or al, al               ; Check for null terminator
    jz .done

    mov ah, 0x0E            ; BIOS teletype function
    int 0x10                ; Call BIOS interrupt
    jmp .loop

.done:
    pop ax
    pop si
    ret



main:
    ;Data Segment 
    mov ax, 0
    mov ds, ax
    mov es, ax

    ;Stack Segment
    mov ss, ax
    mov sp, 0x7C00

    ;Print message
    mov si, msg
    call puts

    hlt

.halt:
    jmp .halt


msg: db 'Hello world!', ENDL, 0


times 510-($-$$) db 0
dw 0AA55h