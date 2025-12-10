org 0x7c00
bits 16

boot:
    mov [boot_drive], dl

    mov bp, 0x9000
    mov sp, bp

    mov bx, REAL_MODE_MSG
    call bios_print

    call kernel_load
    call pm_switch

; loads the kernel
kernel_load:
    mov bx, KERNEL_MSG
    call bios_print

    mov bx, KERNEL_OFFSET
    mov al, 30
    mov bl, [boot_drive]
    call bios_disk_read

    ret

bits 32

pm_begin:
    call KERNEL_OFFSET

%include "bios.asm"
%include "gdt.asm"
%include "pm.asm"

REAL_MODE_MSG db "Switching to protected mode...", 0xa, 0
KERNEL_MSG db "Loading the kernel...", 0xa, 0

KERNEL_OFFSET equ 0x1000

boot_drive db 0

times 510 - ($ - $$) db 0
dw 0xaa55
