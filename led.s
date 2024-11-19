.equ RED_LED_ADDR, 0x10000000   # Endereço base dos LEDs vermelhos
.equ ASCII_ZERO, 0x30           # Código ASCII do caractere '0'
.equ ASCII_ONE, 0x31            # Código ASCII do caractere '1'

.global led_control

led_control:
    # Salvar registradores no stack frame
    addi sp, sp, -20            # Espaço para 5 registradores
    stw r8, 16(sp)
    stw r9, 12(sp)
    stw r10, 8(sp)
    stw r11, 4(sp)
    stw r12, 0(sp)

    # Obter endereço do buffer de comando
    movia r8, CMD_BUFFER

    # Lógica para decidir ação (acender ou apagar)
    ldb r9, 1(r8)               # Segundo caractere do comando
    subi r9, r9, ASCII_ZERO     # Converte para valor numérico
    beq r9, r0, acender_led     # Se igual a '0', acender
    subi r9, r9, 1              # Verifica se é '1'
    beq r9, r0, apagar_led      # Se igual a '1', apagar
    br end_led_control          # Caso contrário, retornar

acender_led:
    # Obter índice do LED
    call calcula_indice
    # Atualizar estado do LED para "acender"
    movia r10, RED_LED_ADDR
    ldwio r11, 0(r10)           # Ler estado atual dos LEDs
    addi r12, r0, 1             # Máscara inicial (0b0001)
    sll r12, r12, r9            # Shift para a posição do LED
    or r11, r11, r12            # Acender o LED correspondente
    stwio r11, 0(r10)           # Escrever novo estado
    br end_led_control          # Finalizar

apagar_led:
    # Obter índice do LED
    call calcula_indice
    # Atualizar estado do LED para "apagar"
    movia r10, RED_LED_ADDR
    ldwio r11, 0(r10)           # Ler estado atual dos LEDs
    addi r12, r0, 1             # Máscara inicial (0b0001)
    sll r12, r12, r9            # Shift para a posição do LED
    not r12, r12                # Inverter bits da máscara
    and r11, r11, r12           # Apagar o LED correspondente
    stwio r11, 0(r10)           # Escrever novo estado
    br end_led_control          # Finalizar

calcula_indice:
    # Calcular índice do LED com base nos dois últimos caracteres do comando
    ldb r9, 3(r8)               # Pegar o penúltimo caractere
    subi r9, r9, ASCII_ZERO     # Converter para número
    slli r9, r9, 3              # Multiplicar por 8
    ldb r10, 4(r8)              # Pegar o último caractere
    subi r10, r10, ASCII_ZERO   # Converter para número
    add r9, r9, r10             # Somar os valores
    ret                         # Retornar índice no registrador r9

end_led_control:
    # Restaurar registradores do stack frame
    ldw r8, 16(sp)
    ldw r9, 12(sp)
    ldw r10, 8(sp)
    ldw r11, 4(sp)
    ldw r12, 0(sp)
    addi sp, sp, 20             # Restaurar stack
    ret                         # Retornar para a chamada
