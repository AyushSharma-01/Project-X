## Project-X — Copilot instructions

This file helps AI coding agents get productive quickly in the Project-X bootloader repository.

High level
- This repo builds a two-stage x86 real-mode -> protected-mode bootloader (NASM). See `src/main.asm` (stage1, org 0x7C00) and `src/loader_stage_2.asm` (stage2, org 0x7E00).
- BIOS loads the first sector (stage1) at 0x7C00. Stage1 uses INT 13h (AH=0x02) to read the next sector (CH=0 CL=2 DH=0 AL=1) into physical address 0x7E00. Stage1 then far-jumps to 0x07E0:0x0000.

Build and run (repo-specific)
- Primary (Windows): run `build.bat` from the repo root. It uses `nasm` and PowerShell to pad the floppy image: build\main_floppy.img.
- Cross-platform makefile: `make` target `all` (requires GNU tools: `nasm`, `cat`, `truncate`). Outputs `build/main_floppy.img` by concatenating `build/main.bin` + `build/loader_stage_2.bin`.
- Manual assemble examples:
  - `nasm src/main.asm -f bin -o build/main.bin`
  - `nasm src/loader_stage_2.asm -f bin -o build/loader_stage_2.bin`

Design & conventions to preserve
- Use `org` and `bits 16` for stage1 (boot sector) and `org 0x7E00` for stage2.
- stage1 must fit in one 512-byte sector. In `src/main.asm` you can see the `times` padding and `dw 0xAA55` boot signature.
- stage2 is assembled as a raw binary (no BIOS signature required). It currently uses `dw 0xAAAA` as a filler — changing this must be deliberate.
- Segment arithmetic: the code converts physical addresses and segment:offset pairs using paragraph units (e.g., segment 0x07E0 => physical 0x7E00). Keep this when doing far jumps.
- Stack placement: both stages use SS=0 and SP=0x7BFF (stack below 0x7C00). Preserve this when modifying early-stage code.

Important code patterns (examples)
- Disk I/O: `int 0x13`, AH=0x02 to read a single sector. See `src/main.asm` stage_2 routine.
- Printing: BIOS teletype AH=0x0E via `int 0x10`. See `puts` in `src/loader_stage_2.asm` and the small print routine in `src/main.asm`.
- A20 enable: implemented in `src/loader_stage_2.asm` (keyboard controller method). This routine polls port 0x64 and writes to 0x60.
- Entering protected mode: loader_stage_2 uses a GDT load + sets CR0.PE then far-jumps to a protected-mode selector (note GDT contents are a placeholder and must be implemented before relying on protected-mode code).

Integration & external dependencies
- Requires `nasm` in PATH. For emulation / debugging prefer `qemu` or `bochs`.
- Recommended QEMU command (PowerShell):
  - `qemu-system-i386 -fda build\main_floppy.img -boot a -m 16 -serial stdio`
  - For GDB debugging: add `-S -gdb tcp::1234` to pause CPU and allow a GDB connection.

Gotchas & notes for edits
- Do not increase stage1 size above 512 bytes; the BIOS only loads the first sector at boot.
- Stage1 loads sector 2 (CL=2). If you change the image layout, update both `main.asm` and the build script that concatenates binaries.
- The makefile uses `truncate`/`cat` which are UNIX utilities; on Windows prefer `build.bat` (PowerShell-based padding).
- `loader_stage_2.asm` contains placeholders: `GDT_Descriptor` and `GDT_Start` are currently empty. Implementing protected-mode code requires filling those.

Where to look first
- `src/main.asm` — boot record, disk read and basic error printing
- `src/loader_stage_2.asm` — A20, GDT loading, protected-mode entry point, and print helpers
- `build.bat` / `makefile` — platform-specific build steps and image padding

When unsure, ask for:
- Clarification whether stage2's GDT should be a minimal identity-mapped GDT (I can add an example) or a more complex layout.
- Target testing environment (QEMU vs real hardware vs Bochs) — some instructions differ.

If you want, I can:
- Add a minimal working GDT and a tiny protected-mode C/ASM stub that prints using a serial port (low risk).
- Add a `README.md` with the same quickstart notes.

---
Please review any missing repo-specific details you'd like included (e.g., preferred emulator, completion of GDT in `src/loader_stage_2.asm`).
