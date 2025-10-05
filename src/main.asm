org 0x7C00
bits 16

%DEFINE ENDL 0x0D, 0x0A

start:
    jmp main

stage_2:
    ; Save registers
    push si
    push ax

    ; Load stage2 from disk
    mov es, 0x07E0        ; segment of stage2 (0x7E00 >> 4)
    mov bx, 0x0000        ; offset
    mov ch, 0             ; cylinder
    mov cl, 1             ; sector (1-based)
    mov dh, 0             ; head
    mov ah, 0x02          ; read sectors
    mov al, 1             ; read 1 sector
    int 13h

    jc handle_error        ; if CF=1, error
    call done

.handle_error:
    mov al, ah            ; move BIOS error code to AL
    mov ah, 0x0E          ; teletype function
    int 0x10
    jmp .halt

.done:
    ; Far jump to stage2 at 0x7E00
    push 0x0000           ; IP = 0x0000
    push 0x07E0           ; CS = 0x07E0
    retf

.halt:
    hlt
    jmp .halt

main:
    ; Set segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; Stack setup (safe memory below stage2)
    mov ss, ax
    mov sp, 0x7BFF

    call stage_2

times 510-($-$$) db 0
dw 0xAA55