org 0x7E00
bits 16

%DEFINE ENDL 0x0D, 0x0A

CODE_SEG equ Code_Descriptor - GDT_start
DATA_SEG equ Data_Descriptor - GDT_start

start:
    jmp main



procmd:

    cli                                      ;disable interrupts
    jmp .A20_Enable                           ;enable A20 line
    
    lgdt [GDT_Descriptor]                    ;load GDT
    
    mov eax, cr0
    or eax, 1                                ;set PE bit
    mov cr0, eax                             ;enter protected mode
    jmp CODE_SEG:protected_mode_entry        ;jump to protected mode code

    jmp $


.A20_Enable:            ;enable A20 line (kbc method)
    push ax

.wait_ibf1:
    in al, 0x64          ; read status port
    test al, 2           ; bit 1 = input buffer full?
    jnz .wait_ibf1       ; wait until input buffer empty

    mov al, 0xD1         ; command: write output port
    out 0x64, al

.wait_ibf2:
    in al, 0x64
    test al, 2
    jnz .wait_ibf2       ; wait again

    mov al, 0xDF         ; enable A20 (bit 1 = 1)
    out 0x60, al
    ret


GDT_start:
    Null_Descriptor:
        dd 0 ;four times  00000000
        dd 0 ;fout times  00000000

    Code_Descriptor:
        dw 0xFFFF          ; limit low
        dw 0x0000          ; base low
        db 0x00            ; base middle
        db 10011010b       ; access: present=1, ring=0, code segment, executable+readable
        db 11001111b       ; flags: 4K granularity, 32-bit, limit high 4 bits
        db 0x00            ; base high

    Data_Descriptor:
        dw 0xFFFF          ; limit low
        dw 0x0000          ; base low
        db 0x00            ; base middle
        db 10010010b       ; access: present=1, ring=0, data segment, writable
        db 11001111b       ; flags: 4K granularity, 32-bit, limit high 4 bits
        db 0x00            ; base high
GDT_end:


puts:                               ;prints msg
    ; Save registers
    push si
    push ax

.loop:   
    lodsb                          ; load byte at DS:SI into AL, increment SI
    or al, al
    jz .done

    mov ah, 0x0E                   ; BIOS teletype function
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
    lea si, (msg-0x7E00)   ; Load offset of msg into SI relative to DS(0x07E x 10)
    call puts
    call procmd


; Halt CPU
.halt:  
    hlt
    jmp .halt




protected_mode_entry:
    [bits 32]

    ; Print protected mode message
    mov al, "1"
    mov ah, 0x0f
    mov [0xB8000], ax        ; Print '1' at top-left corner

    ; Hang the system
    jmp $



GDT_Descriptor:
    dw GDT_end - GDT_start - 1
    dd GDT_start



msg: db 'initializing protected mode...', ENDL, 0

; Pad stage2 to 512 bytes
times 510-($-$$) db 0
dw 0xAAAA