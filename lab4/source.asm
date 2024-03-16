; Вариант 4: 4.	Дан массив из 10 байт. Посчитать количество байт с числом единиц в байте равным три.
DATA_S segment
DATA_S ends
CODE_S segment
    assume cs: CODE_S, ds: DATA_S
    ; Вывод строки
    WRITESTR proc
        xor ax, ax
        mov ah, 09h
        lea dx, msg
        int 21h
        ret
    WRITESTR endp
    ; Вывод значения
    WRITENUM proc
        mov ax, val
        mov cx, 10          ; Делитель - система счисления
        mov bx, 0           ; Счетчик цифр в числе
        addition_loop:
            xor dx, dx      ; Очистить регистр dx
            div cx          ; Получаем остаток от деления на СС -> Последняя цифра
            add dl, '0'     ; Добавляем 0 для конца символа
            push dx
            inc bx
            cmp ax, 0
            jne addition_loop
        print_loop:
            pop dx          ; Вытаскиваем число
            mov ah, 02h     ; Вывод на дисплей
            int 21h         ; одного символа
            dec bx
            cmp bx, 0
            jne print_loop
        ret
    WRITENUM endp
    start:
    quit:
        mov ah, 4ch
        int 21h
CODE_S ends
end start