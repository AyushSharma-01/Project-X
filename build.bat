@echo off
setlocal enabledelayedexpansion
title Building OS...

:: === CONFIG ===
:: Add your cross-compiler tools to PATH
set PATH=C:\D Drive\i686-elf-tools-windows\bin;%PATH%

set NASM=nasm
set GCC=i686-elf-gcc
set LD=i686-elf-ld
set OBJCOPY=i686-elf-objcopy

set OUTDIR=build

:: === CLEAN OLD FILES ===
if exist %OUTDIR% rd /s /q %OUTDIR%
mkdir %OUTDIR%

echo [1/6] Assembling stage 1 bootloader...
%NASM% -f bin boot\main.asm -o %OUTDIR%\main.bin
if errorlevel 1 goto :error

echo [2/6] Assembling stage 2 loader...
%NASM% -f bin boot\loader_stage_2.asm -o %OUTDIR%\loader_stage_2.bin
if errorlevel 1 goto :error

echo [3/6] Compiling kernel C code...
%GCC% -m32 -ffreestanding -fno-pie -c kernel\kernel.c -o %OUTDIR%\kernel.o
if errorlevel 1 goto :error

echo [4/6] Linking kernel ELF...
%LD% -m elf_i386 -T linker.ld -nostdlib -o %OUTDIR%\kernel.elf %OUTDIR%\kernel.o
if errorlevel 1 goto :error

echo [5/6] Converting kernel to binary...
%OBJCOPY% -O binary %OUTDIR%\kernel.elf %OUTDIR%\kernel.bin
if errorlevel 1 goto :error

echo [6/6] Creating final OS image...
copy /b %OUTDIR%\main.bin + %OUTDIR%\loader_stage_2.bin + %OUTDIR%\kernel.bin %OUTDIR%\os-image.bin >nul
if errorlevel 1 goto :error

echo.
echo Build complete! Output: %OUTDIR%\os-image.bin
pause
exit /b 0

:error
echo.
echo [ERROR] Build failed.
pause
exit /b 1
