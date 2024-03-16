; Вариант 8: X = 6C + (B - C + 1)/2
data segment
b dw 2
c dw 1
x dw ?
data ends
code segment
    assume cs: code, ds: data
    start: mov ax, data
        mov ds, ax
        mov ax, c
    mov bx, ax
    shl ax, 2   ; 4С
    shl bx, 1   ; 2C
    add ax, bx  ; 4C + 2C = 6C
    mov cx, b   ; B
    sub cx, c   ; B - C
    inc cx      ; B - C + 1
    shr cx, 1   ; (B - C + 1)/2
    add ax, cx  ; Ответ: 33d / 21h
    mov x, ax
    quit:
        mov ax, 4c00h
        int 21
code ends
end start