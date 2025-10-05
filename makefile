# Makefile for building bootloader and floppy image



ASM = nasm

SRC_DIR = src
BUILD_DIR = build

# Build stage1 binary
$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin

# Build stage2 binary
$(BUILD_DIR)/loader_stage_2.bin: $(SRC_DIR)/loader_stage_2.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/loader_stage_2.asm -f bin -o $(BUILD_DIR)/loader_stage_2.bin

# Build the full floppy image
$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/main.bin $(BUILD_DIR)/loader_stage_2.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main_floppy.img
	dd if=$(BUILD_DIR)/loader_stage_2.bin of=$(BUILD_DIR)/main_floppy.img bs=512 seek=1 conv=notrunc
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)