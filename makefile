all: os-image.bin

boot/main.bin: boot/main.asm
	nasm -f bin $< -o $@

boot/loader_stage2.bin: boot/loader_stage2.asm
	nasm -f bin $< -o $@

kernel/kernel.o: kernel/kernel.c
	gcc -m32 -ffreestanding -c $< -o $@

kernel.elf: kernel/kernel.o
	ld -m elf_i386 -T linker.ld -o $@ $<

kernel.bin: kernel.elf
	objcopy -O binary $< $@

os-image.bin: boot/main.bin boot/loader_stage2.bin kernel.bin
	cat $^ > $@

clean:
	rm -f boot/*.bin boot/*.o kernel/*.o kernel.elf kernel.bin os-image.bin
