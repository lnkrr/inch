%ifndef GDT_ASM
%define GDT_ASM

gdt_start:

gdt_null:
    dd 0
    dd 0

gdt_code:
    dw 0xffff ; limit
    db 0, 0, 0 ; base
    db 0b10011010 ; first flags, type flags
    db 0b11001111 ; second flags, limit
    db 0 ; base

gdt_data:
    dw 0xffff ; limit
    db 0, 0, 0 ; base
    db 0b10010010 ; first flags, type flags
    db 0b11001111 ; second flags, limit
    db 0 ; base

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; gdt size
    dd gdt_start

CODE_SEGMENT equ gdt_code - gdt_start
DATA_SEGMENT equ gdt_data - gdt_start

%endif
