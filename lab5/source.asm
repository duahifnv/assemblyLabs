 DATA_S segment
    str_len db ?
    sub_len db ?
    str_input db 80, ?, 82 dup (?)
    sub_input db 80, ?, 82 dup (?)
    str_prefix db 'Enter string: $'
    sub_prefix db 0dh, 0ah, 'Enter substring: $'
    msg_yes db 0dh, 0ah, 'YES$'
    msg_no db 0dh, 0ah, 'NO$'
    msg_sub_over_error db 0dh, 0ah, 'Error: Substring is longer than string$'
    ; output_idx db 0dh, 0ah, 'Index of first entrance: ', '$'
DATA_S ends
CODE_S segment
    assume cs: CODE_S, ds: DATA_S
    start:
        mov ax, DATA_S  
        mov ds, ax
        xor ax, ax  ; Clean ax
        ; Input str_prefix
        mov ah, 09h
        lea dx, str_prefix
        int 21h
        ; Output str_prefix
        mov ah, 0ah
        lea dx, str_input
        int 21h
        ; Input sub_prefix
        mov ah, 09h
        lea dx, sub_prefix
        int 21h
        ; Output sub_prefix
        mov ah, 0ah
        lea dx, sub_input
        int 21h
        mov dh, [str_input + 1]   ; Length of string
        mov str_len, dh
        mov dl, [sub_input + 1]   ; Length of substring
        mov sub_len, dl
        cmp dh, dl
        jb sub_over_error   ; ERROR: Substring longer than string
        lea si, str_input + 2     ; String offset
        lea di, sub_input + 2     ; Substring offset
        
        mov bl, 0           ; Number of characters found in a row
        mov cl, str_len     ; LOOP (CX)
        next_val:
            mov al, [si]
            mov ah, [di + bx]
            inc si
            cmp al, ah      ; Comparing current string char
                            ; with indexed substring char
            je equal
        not_equal:
            mov bl, 0       ; Reset counter
            loop next_val
            jmp no          ; Wasnt found
        equal:
            inc bl          ; Increase substring counter
            cmp bl, sub_len ; Substr counter == Length of substring?
            jz yes
            loop next_val
        no:
            mov ah, 09h
            lea dx, msg_no
            int 21h
            jmp quit
        yes:
            mov ah, 09h
            lea dx, msg_yes
            int 21h
            jmp quit
        sub_over_error:
            mov ah, 09h
            lea dx, msg_sub_over_error
            int 21h
    quit:
        mov ah, 4ch
        int 21h
CODE_S ends
end start