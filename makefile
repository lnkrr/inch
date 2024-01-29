SRC_DIR := src
INCLUDE_DIR := include

SRC_BOOT_DIR := $(SRC_DIR)/boot
SRC_KERNEL_DIR := $(SRC_DIR)/kernel

SRC_KERNEL_C_DIR := $(SRC_KERNEL_DIR)/c
SRC_KERNEL_ASM_DIR := $(SRC_KERNEL_DIR)/asm

OBJ_DIR := obj
BIN_DIR := bin
BUILD_DIR := build

OBJ_BOOT_DIR := $(OBJ_DIR)/boot
OBJ_KERNEL_DIR := $(OBJ_DIR)/kernel

OBJ_KERNEL_C_DIR := $(OBJ_KERNEL_DIR)/c
OBJ_KERNEL_ASM_DIR := $(OBJ_KERNEL_DIR)/asm

ASM := nasm
CC := gcc
LD := ld

QEMU := qemu-system-i386

C_FLAGS := -Wall -Wextra -Wpedantic -ffreestanding -fno-pie -O3 -c -m32 -I$(INCLUDE_DIR) -I$(INCLUDE_DIR)/inch/libc -nostdinc -nostdlib
ASM_FLAGS := -Wall

LD_FLAGS := -melf_i386 -no-pie

SRC_KERNEL_C_FILES := $(wildcard $(SRC_KERNEL_C_DIR)/**/*.c $(SRC_KERNEL_C_DIR)/*.c)
SRC_KERNEL_ASM_FILES := $(wildcard $(SRC_KERNEL_ASM_DIR)/**/*.asm $(SRC_KERNEL_ASM_DIR)/*.asm)
SRC_KERNEL_FILES := $(SRC_KERNEL_C_FILES) $(SRC_KERNEL_ASM_FILES)

OBJ_KERNEL_C_FILES := $(patsubst $(SRC_KERNEL_DIR)/%.c,$(OBJ_KERNEL_DIR)/%.o,$(SRC_KERNEL_C_FILES))
OBJ_KERNEL_ASM_FILES := $(patsubst $(SRC_KERNEL_DIR)/%.asm,$(OBJ_KERNEL_DIR)/%.o,$(SRC_KERNEL_ASM_FILES))
OBJ_KERNEL_FILES := $(OBJ_KERNEL_C_FILES) $(OBJ_KERNEL_ASM_FILES)

BOOT_BIN := $(BIN_DIR)/boot.bin
KERNEL_BIN := $(BIN_DIR)/kernel.bin

TARGET := $(BUILD_DIR)/inch

all: $(TARGET)

$(TARGET): $(BOOT_BIN) $(KERNEL_BIN) | $(BUILD_DIR)
	cat $^ > $(TARGET)

$(BOOT_BIN): $(SRC_BOOT_DIR)/boot.asm | $(BIN_DIR)
	$(ASM) -o $@ $< $(ASM_FLAGS) -fbin -i$(SRC_BOOT_DIR)/include

$(KERNEL_BIN): $(OBJ_KERNEL_FILES) | $(BIN_DIR)
	$(LD) -o $@ $^ $(LD_FLAGS) -Ttext 0x1000 --oformat binary

$(OBJ_KERNEL_ASM_DIR)/%.o: $(SRC_KERNEL_ASM_DIR)/%.asm
	mkdir -p $(@D)

	$(ASM) -o $@ $< $(ASM_FLAGS) -felf

$(OBJ_KERNEL_C_DIR)/%.o: $(SRC_KERNEL_C_DIR)/%.c
	mkdir -p $(@D)

	$(CC) -o $@ $< $(C_FLAGS)

$(BUILD_DIR) $(BIN_DIR) $(OBJ_DIR):
	mkdir -p $@

run: $(TARGET)
	$(QEMU) -fda $^

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(OBJ_DIR)

.PHONY: all clean run
