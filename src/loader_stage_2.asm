org 0x7E00
bits 16

%DEFINE ENDL 0x0D, 0x0A

start:
    jmp main

puts:
    push ax
    push si

.loop:
    lodsb           ; load byte at DS:SI into AL, increment SI
    or al, al
    jz .done

    mov ah, 0x0E    ; BIOS teletype function
    int 0x10
    jmp .loop

.done:
    pop si
    pop ax
    ret


main:
    ; Set data segment to stage2
    mov ax, 0x07E0
    mov ds, ax
    mov es, ax

    ; Safe stack setup (below stage2)
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x7BFF

    ; Print message
    mov si, msg
    call puts

; Halt CPU
.halt:  
    hlt
    jmp .halt

msg: db 'Hello world 2!', ENDL, 0

; Pad stage2 to 512 bytes
times 510-($-$$) db 0
dw 0xAAAA