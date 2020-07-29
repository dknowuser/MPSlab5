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
init_serial_port:
	;Стек растёт вверх - указатель указывает на первый байт после программы
	mov SP, #stack
	
	;Установка режима работы таймера T/C1
	mov TMOD, #20h
	
	;Начальное значение таймера
	mov TH1, #0F4h
	
	mov R0, #EXTERNAL_DATA_MEMORY
	mov R1, #00h; Сколько байт передано
	
	mov SCON, #50h; Приём данных в режиме 8-разрядного УАПП

	;Запуск таймера T/C1
	mov TCON, #40h
	
wait_for_transmitter:
	mov A, P3
	anl A, #10h; Выделяем сигнал готовности передатчика
	clr C
	subb A, #10h
	jnz wait_for_transmitter
	
	;Сбрасываем сигнал готовности приёмника
	mov A, P3
	anl A, #0DFh
	mov P3, A
	
	;Считываем значение из последовательного порта
	mov @R0, SBUF
	
	;Подготовка к чтению следующего байта
	mov A, R1
	clr C
	subb A, #EXTERNAL_DATA_MEMORY_SIZE
	jnz not_zero
	mov R1, #00h; Возвращаемся в начало записываемой области памяти
	mov R0, #EXTERNAL_DATA_MEMORY

not_zero:
	inc R1
	inc R0
	
	;Устанавливаем сигнал готовности приёмника
	mov A, P3
	orl A, #20h
	mov P3, A
	
	;Сбрасываем флаг прерывания последовательного порта
	clr SCON.0
	
;Конец программы
	jmp wait_for_transmitter	
	
stack:

END