org 0x7c00
bits 16


%define END_LINE 0x0D, 0x0A 

;
;   FAT 12 HEADER
; 
jmp short start
nop                     ; do nothing 


; BIOS PARAMETER BLOCK (bpb)
bpb_oem:                        db 'MSWIN4.1'           ; 8 bytes 
bpb_bytes_per_sector:           dw 512                  ; 0x0002 in little-endian format wich is 0x0200 in hex 
                                                        ; 2 bytes
bpb_sector_by_cluster:          db 1                    ; 1 byte
bpb_reserved_sector:            dw 1                    ; 2 bytes
bpb_nb_fat:                     db 2                    ; 1 byte
bpb_nb_root_dir:                dw 0E0h                 ; 2 bytes
bpb_total_logical_volume:       dw 2880                 ; 2 bytes (0x0B40)
bpb_media_descriptor_file:      db 0F0H                 ; 1 byte
bpb_nb_sector_by_fat:           dw 9                    ; 2 bytes
bpb_nb_sector_by_track:         dw 18                   ; 2 bytes
bpb_nb_head_or_side:            dw 2                    ; 2 bytes
bpb_hidden_sectors:             dd 0                    ; 4 bytes
bpb_large_sector_count:         dd 0                    ; 4 bytes 

; EXTEND BOOT RECORD (ebr)
ebi_drive_number:               db 0                    ; 1 byte
                                db 0                    ; 1 byte (reserved windows NT)
ebi_signature:                  db 29h                  ; 1 byte
ebi_volume_id:                  db 69h, 69h, 69h, 69h   ; 4 bytes
ebi_volume_index:               db 'BruhOS     '        ; 11 bytes
ebi_system_id:                  db 'FAT12   '           ; 8 bytes



start:
    jmp main


; print the string to tty
printString:

    push si             ; push register that we will modify
    push ax


.printloop:
    lodsb               ; load next char in al
    or al, al           ; if result of al and al is 0, 
                        ; which only happens when al is 0 and set the zero flag
                        ; 0 represent the end of the string
    jz .done
    
    mov ah, 0x0e        ; setup bios interupt call for printing char       
    int 10h

    jmp .printloop
    
; clear registery
.done: 
    pop ax
    pop si
    ret                 ; return to the caller


; capture keyboard input until the scan code in bl is press
key_press:
    push bx
    push ax

.keyboard_loop:
    mov ah,0x0
    int 16h
    cmp ah,bl
    je  .done

.done:     
    pop ax
    pop bx
    ret                 ; return to the caller


main:
    ; setup data segment
    mov ax,0
    mov ds, ax
    mov es, ax
    ; setup stack
    mov ss, ax
    mov sp, 0x7C00

    
    mov ah, 0x0         
    mov al, 0x3
    int 0x10

    mov si, welcome_msg ; print welcome msg
    call printString

    mov bl, 0x1c        ; wait to press enter           
    call key_press
    
    mov ah,0h           ; scroll down the screen (clear it) when ent
    mov al, 3h
    int 10h

    mov si, start_msg   ; print starting os msg
    call printString
    
    

    hlt

.halt:
    jmp .halt


welcome_msg:    db "Welcome to Simple Bootloader press enter to continue ...", END_LINE, 0
start_msg:      db "Starting OS....", END_LINE, 0


times 510-($-$$) db 0
dw 0xAA55
