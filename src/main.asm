org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main

stage_2:
    ; Save registers
    push si
    push ax

    ; Load stage2 from disk
    mov ax, 0x07E0        ; segment where stage2 will be loaded
    mov es, ax            ; segment of stage2 (0x7E00 >> 4)
    mov bx, 0x0000        ; offset
    mov ch, 0             ; cylinder
    mov cl, 2             ; sector
    mov dh, 0             ; head
    mov ah, 0x02          ; read sectors
    mov al, 1             ; read 1 sector
    int 13h

    jc handle_error       ; if CF=1, error
    call done

handle_error:
    mov al, ah            ; move BIOS error code to AL

    ; Print value of AL as hex
    mov ah, 0x0E
    mov bl, al
    shr al, 4
    add al, '0'
    cmp al, '9'
    jbe print_high
    add al, 7

print_high:
    int 0x10

    mov al, bl
    and al, 0x0F
    add al, '0'
    cmp al, '9'
    jbe print_low
    add al, 7

print_low:
    int 0x10

    ; Print newline
    mov si, endl_chars

print_endl:
    lodsb
    or al, al
    jz done_endl
    mov ah, 0x0E
    int 0x10
    jmp print_endl

done_endl:
    jmp halt

done:
    ; Far jump to stage2 at 0x7E00
    push 0x0000           ; IP = 0x0000
    push 0x07E0           ; CS = 0x07E0
    retf

halt:
    hlt
    jmp halt

endl_chars: db ENDL, 0

main:
    ; Set segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; Stack setup (safe memory below stage2)
    mov ss, ax
    mov sp, 0x7BFF

    call stage_2

times 510 - ($ - $$) db 0
dw 0xAA55                   ; Boot signature