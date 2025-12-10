%ifndef BIOS_ASM
%define BIOS_ASM

bits 16

; prints a null-terminated string to the screen
; bx is a pointer to the beginning of the string
bios_print:
    push ax

.loop:
    mov al, [bx]

    cmp al, 0
    je .done

    call bios_print_char

    inc bx
    jmp .loop

.done:
    pop ax
    ret

; prints a character to the screen
; al is the character to print
bios_print_char:
    cmp al, 0xa
    je .newline

    call bios_print_char_raw
    jmp .done

.newline:
    mov al, 0xd
    call bios_print_char_raw

    mov al, 0xa
    call bios_print_char_raw

.done:
    ret

bios_print_char_raw:
    push ax

    mov ah, 0xe
    int 0x10

    pop ax
    ret

; reads n sectors to es:bx from a drive
; al is the amount of sectors to read
; bl is the drive to read
bios_disk_read:
    push bx
    push dx
    push cx

    mov dl, bl
    mov ch, 0
    mov dh, 0
    mov cl, 2 ; start reading after the boot sector

    mov ah, 0x2

    push ax

    int 0x13
    jc .error

    mov bl, al

    pop ax

    cmp bl, al
    jne .error

    pop cx
    pop dx
    pop bx

    ret

.error:
    mov bx, DISK_ERROR
    call bios_print

    jmp $

DISK_ERROR db "Failed to read the disk", 0xa, 0

%endif
