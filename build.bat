@echo off
REM ----------------------------
REM Build bootloader floppy image
REM ----------------------------

REM Create build directory
if not exist build mkdir build

REM Assemble stage1
echo Assembling stage1...
nasm src\main.asm -f bin -o build\main.bin
if errorlevel 1 (
    echo Error: Failed to assemble main.asm
    pause
    exit /b 1
)

REM Assemble stage2
echo Assembling stage2...
nasm src\loader_stage_2.asm -f bin -o build\loader_stage_2.bin
if errorlevel 1 (
    echo Error: Failed to assemble loader_stage_2.asm
    pause
    exit /b 1
)

REM Combine into floppy image
echo Combining stage1 and stage2 into floppy image...
copy /b build\main.bin+build\loader_stage_2.bin build\main_floppy.img /y

REM Pad to 1.44 MB using PowerShell
echo Padding floppy image to 1.44 MB...
powershell -Command ^
"$f='build\main_floppy.img'; ^
$size=1440*1024; ^
$current=(Get-Item $f).Length; ^
if($current -lt $size){$fs=[IO.File]::Open($f,'Open','ReadWrite'); $fs.SetLength($size); $fs.Close()}"

echo Build complete!
pause
