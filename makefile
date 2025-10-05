# Makefile for building bootloader and floppy image on Windows

ASM = nasm
SRC_DIR = src
BUILD_DIR = build

STAGE1 = $(SRC_DIR)/main.asm
STAGE2 = $(SRC_DIR)/loader_stage_2.asm

STAGE1_BIN = $(BUILD_DIR)/main.bin
STAGE2_BIN = $(BUILD_DIR)/loader_stage_2.bin
FLOPPY_IMG = $(BUILD_DIR)/main_floppy.img

# Default target
all: $(FLOPPY_IMG)

# Create build directory (Windows CMD syntax)
$(BUILD_DIR):
	if not exist $(BUILD_DIR) mkdir $(BUILD_DIR)

# Assemble stage1
$(STAGE1_BIN): $(STAGE1) | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Assemble stage2
$(STAGE2_BIN): $(STAGE2) | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Build floppy image: copy stage1 + stage2
$(FLOPPY_IMG): $(STAGE1_BIN) $(STAGE2_BIN)
	@echo Creating floppy image...
	copy /b $(STAGE1_BIN)+$(STAGE2_BIN) $(FLOPPY_IMG)
	@echo Padding floppy image to 1.44 MB...
	@powershell -Command "$f = '$(FLOPPY_IMG)'; $size = 1440*1024; $current = (Get-Item $f).Length; if($current -lt $size){$fs = [IO.File]::Open($f,'Open','ReadWrite'); $fs.SetLength($size); $fs.Close() }"

# Clean build artifacts
clean:
	if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR)