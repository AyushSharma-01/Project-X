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

# Ensure build directory exists
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Assemble stage1
$(STAGE1_BIN): $(STAGE1) | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Assemble stage2
$(STAGE2_BIN): $(STAGE2) | $(BUILD_DIR)
	$(ASM) $< -f bin -o $@

# Build full floppy image: stage1 + stage2, then pad to 1.44MB
$(FLOPPY_IMG): $(STAGE1_BIN) $(STAGE2_BIN)
	cat $(STAGE1_BIN) $(STAGE2_BIN) > $@
	truncate -s 1440k $@

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
