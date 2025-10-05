org 0x7E00
bits 16

%DEFINE ENDL 0x0D, 0x0A

start:
    jmp main

puts:
    ; Save registers
    push si
    push ax

.loop:
    lodsb                  ; Load byte at DS:SI into AL and increment SI
    or al, al              ; Check for null terminator
    jz .done

    mov ah, 0x0E           ; BIOS teletype
    int 0x10
    jmp .loop

.done:
    pop ax
    pop si
    ret

main:
    ; Data Segment pointing to stage2
    mov ax, 0x07E0
    mov ds, ax
    mov es, ax

    ; Stack setup
    mov ss, ax
    mov sp, 0x7BFF

    ; Print message
    mov si, msg
    call puts

    hlt
.halt:
    jmp .halt

msg: db 'Hello world 2!', ENDL, 0

times 512-($-$$) db 0
