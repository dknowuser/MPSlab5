$MOD52

;Данная программа обеспечивает ввод массива символьной информации
;в ВПД, через канал последовательного ввода/вывода
;с использованием сигналов квитирования (готовность передатчика,
;готовность приёмника). Для формирования сигналов квитирования
;используются линии P3.4 и P3.5. 
;Скорость вывода - 2400 бод.

EXTERNAL_DATA_MEMORY EQU 80h
EXTERNAL_DATA_MEMORY_SIZE EQU 70h
BYTE_NUMBER EQU 30h
ADDRESS EQU 31h

ORG 00h
	jmp init_serial_port
	
ORG 23h
	;Сохраняем регистры на время работы обработчика прерывания
	mov R2, A
	mov R3, PSW

	;Сбрасываем сигнал готовности приёмника
	mov A, P3
	anl A, #0DFh
	mov P3, A
	
	;Считываем значение из последовательного порта
	mov A, @R0
	mov R0, A
	mov @R0, SBUF
	
	;Подготовка к чтению следующего байта
	mov A, @R1
	clr C
	subb A, #EXTERNAL_DATA_MEMORY_SIZE
	jnz not_zero
	mov @R1, #00h; Возвращаемся в начало записываемой области памяти
	mov R0, #ADDRESS
	mov @R0, #EXTERNAL_DATA_MEMORY
	jmp continue
	
not_zero:
	inc @R1
	mov R0, #ADDRESS
	inc @R0

continue:
	
	;Устанавливаем сигнал готовности приёмника
	mov A, P3
	orl A, #20h
	mov P3, A
	
	;Восстанавливаем регистры
	mov A, R2
	mov PSW, R3
	mov R2, #00h
	mov R3, #00h
	mov R0, #ADDRESS
	mov R1, #BYTE_NUMBER; Сколько байт получено
	
	;Сбрасываем флаг прерывания получения байта последовательного порта
	clr SCON.0
	reti

init_serial_port:
	;Стек растёт вверх - указатель указывает на первый байт после программы
	mov SP, #stack
	
	;Установка режима работы таймера T/C1
	mov TMOD, #20h
	
	;Разрешение прерывания 
	mov IE, #90h
	
	;Устанавливаем высокий приоритет прерывания
	mov IP, #10h
	
	;Начальное значение таймера
	mov TH1, #0F4h
	
	mov R0, #ADDRESS
	mov R1, #BYTE_NUMBER; Сколько байт получено
	
	mov @R1, #00h
	mov @R0, #EXTERNAL_DATA_MEMORY

	;Запуск таймера T/C1
	mov TCON, #40h

	mov SCON, #50h; Приём данных в режиме 8-разрядного УАПП
	
;Конец программы
lp:
	jmp lp
	
stack:

END