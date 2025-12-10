ASM := nasm
CENTC := centc
LD := ld
QEMU := qemu-system-i386

CENT_FLAGS := -O --reloc-model static --emit obj -t i386-pc-elf
ASM_FLAGS := -Wall
LD_FLAGS := -melf_i386 -no-pie

all: build/cent-os.bin

build/cent-os.bin: build/boot.bin build/kernel.bin
	cat $^ > $@

build/boot.bin: src/boot/main.asm
	mkdir -p $(@D)
	$(ASM) -o $@ $< $(ASM_FLAGS) -fbin -Isrc/boot

build/kernel.bin: build/kernel/entry.o build/kernel/main.o
	$(LD) -o $@ $^ $(LD_FLAGS) -Ttext 0x1000 --oformat binary

build/kernel/entry.o: src/kernel/entry.asm
	mkdir -p $(@D)
	$(ASM) -o $@ $< $(ASM_FLAGS) -felf

build/kernel/main.o: src/kernel/main.cn
	mkdir -p $(@D)
	$(CENTC) -o $@ $< $(CENT_FLAGS)

run: build/cent-os.bin
	$(QEMU) -fda $<

clean:
	rm -rf build

.PHONY: all clean run
