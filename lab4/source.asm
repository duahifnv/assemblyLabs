; Вариант 4: 4.	Дан массив из 10 байт. Посчитать количество байт с числом единиц в байте равным три.
DATA_S segment
    msg db 'Amount of 3byte values: $'
    val dw 0
    buff db 01100101b, 01101101b, 01000101b, 00001011b, 01111101b, 00000101b, 00000111b, 01111111b, 01000101b, 01101101b ; 4 значение с тремя единицами
    buff_s db 10
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
    ; Ввод символа (пауза)
    READC proc
        mov ah, 07h
        int 21h
        ret
    READC endp
    start:
        mov ax, DATA_S
        mov ds, ax
        lea bx, buff
        xor ax, ax
        mov ah, buff_s      ; Число значений в массиве
        mov dh, 0           ; Счетчик подходящих значений
    arr:
        mov al, [bx]        ; Загружаем очередное значение в al
        xor dl, dl          ; Очищаем dl (счетчик единиц в значении)
        mov cx, 8           ; 8 раз (8 битов) будем сдвигать регистр влево
        pushl:
            shl al, 1       ; Сдвигаем al на один бит влево
            jnc nextb       ; Если нет переноса (последний бит сброшен)
            inc dl          ; Последний бит не сброшен
        nextb: loop pushl
            cmp dl, 3       ; Единиц в значении 3?
            jne nextv
            inc dh
        nextv:              ; Переход на следующее значение
            inc bx
            dec ah
            cmp ah, 0
            jne arr
        mov dl, dh
        mov dh, 0
        mov val, dx
        call WRITESTR
        call WRITENUM
        call READC
    quit:
        mov ah, 4ch
        int 21h
CODE_S ends
end start