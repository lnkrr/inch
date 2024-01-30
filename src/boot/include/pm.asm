%ifndef PM_ASM
%define PM_ASM

bits 16

; switches to protected mode
pm_switch:
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0b1
    mov cr0, eax

    jmp CODE_SEGMENT:pm_init

bits 32

; initialises the stack and registers and calls pm_begin
pm_init:
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x16000
    mov esp, ebp

    call pm_begin

%include "gdt.asm"

%endif
