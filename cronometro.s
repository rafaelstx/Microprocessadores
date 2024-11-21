.equ DISPLAY, 0x10000020        # Endereço base do display de 7 segmentos
.equ TIMER, 0x10002000          # Endereço base do timer
.equ PB, 0x10000050             # Endereço do botão de pressão
.equ MAX_CICLOS, 5              # Número de ciclos para incrementar o cronômetro
.equ MAX_DIGITO, 9              # Valor máximo de cada dígito (0 a 9)

.global timer_control

timer_control:
    # Salvar registradores no stack frame
    addi sp, sp, -32
    stw r8, 28(sp)
    stw r9, 24(sp)
    stw r10, 20(sp)
    stw r11, 16(sp)
    stw r12, 12(sp)
    stw r13, 8(sp)
    stw r14, 4(sp)
    stw r15, 0(sp)

    # Verificar se o cronômetro está ativo
    movia r8, STATUS_CRONOMETRO
    ldw r9, (r8)
    beq r9, r0, end_timer

    # Verificar se o cronômetro está pausado
    movia r8, PAUSE_CRONOMETRO
    ldw r9, (r8)
    beq r9, r0, end_timer

    # Incrementar contador de ciclos
    movia r8, CONTA_CICLO
    ldw r9, (r8)
    addi r9, r9, 1
    stw r9, (r8)
    movi r10, MAX_CICLOS
    blt r9, r10, end_timer

    # Reseta o contador de ciclos
    movi r9, 0
    stw r9, (r8)

    # Atualizar cronômetro
    call update_cronometro

end_timer:
    # Restaurar registradores do stack frame
    ldw r8, 28(sp)
    ldw r9, 24(sp)
    ldw r10, 20(sp)
    ldw r11, 16(sp)
    ldw r12, 12(sp)
    ldw r13, 8(sp)
    ldw r14, 4(sp)
    ldw r15, 0(sp)
    addi sp, sp, 32
    ret

# Função para gerenciar o botão de pausa/retorno
.global button_control
button_control:
    # Salvar registradores no stack frame
    addi sp, sp, -16
    stw r8, 12(sp)
    stw r9, 8(sp)
    stw r10, 4(sp)
    stw r11, 0(sp)

    movia r8, PAUSE_CRONOMETRO
    ldw r9, (r8)
    beq r9, r0, unpause_timer

pause_timer:
    stw r0, (r8)              # Pausar o cronômetro
    br reset_button

unpause_timer:
    movi r10, 1
    stw r10, (r8)             # Retomar o cronômetro

reset_button:
    movia r11, PB
    stwio r0, 12(r11)         # Resetar estado do botão

    # Restaurar registradores do stack frame
    ldw r8, 12(sp)
    ldw r9, 8(sp)
    ldw r10, 4(sp)
    ldw r11, 0(sp)
    addi sp, sp, 16
    ret

# Função para incrementar os valores do cronômetro
update_cronometro:
    # Incrementar unidade do cronômetro
    movia r8, UNIDADE_CRONOMETRO
    ldw r9, (r8)
    movi r10, MAX_DIGITO
    beq r9, r10, increment_dezena
    addi r9, r9, 1
    stw r9, (r8)
    call update_display
    ret

increment_dezena:
    # Reseta unidade e incrementa dezena
    movi r9, 0
    stw r9, (r8)
    movia r8, DEZENA_CRONOMETRO
    ldw r9, (r8)
    beq r9, r10, increment_centena
    addi r9, r9, 1
    stw r9, (r8)
    call update_display
    ret

increment_centena:
    # Reseta dezena e incrementa centena
    movi r9, 0
    stw r9, (r8)
    movia r8, CENTENA_CRONOMETRO
    ldw r9, (r8)
    beq r9, r10, increment_milhar
    addi r9, r9, 1
    stw r9, (r8)
    call update_display
    ret

increment_milhar:
    # Reseta centena e incrementa milhar
    movi r9, 0
    stw r9, (r8)
    movia r8, MILHAR_CRONOMETRO
    ldw r9, (r8)
    beq r9, r10, reset_timer
    addi r9, r9, 1
    stw r9, (r8)
    call update_display
    ret

reset_timer:
    # Reseta todos os valores do cronômetro
    movia r8, UNIDADE_CRONOMETRO
    stw r0, (r8)
    movia r8, DEZENA_CRONOMETRO
    stw r0, (r8)
    movia r8, CENTENA_CRONOMETRO
    stw r0, (r8)
    movia r8, MILHAR_CRONOMETRO
    stw r0, (r8)
    call update_display
    ret

# Função para atualizar o display
update_display:
    movia r8, DISPLAY

    movia r9, UNIDADE_CRONOMETRO
    ldw r10, (r9)
    movia r11, code7seg
    add r11, r11, r10
    ldb r10, (r11)
    stbio r10, (r8)

    movia r9, DEZENA_CRONOMETRO
    ldw r10, (r9)
    movia r11, code7seg
    add r11, r11, r10
    ldb r10, (r11)
    stbio r10, 1(r8)

    movia r9, CENTENA_CRONOMETRO
    ldw r10, (r9)
    movia r11, code7seg
    add r11, r11, r10
    ldb r10, (r11)
    stbio r10, 2(r8)

    movia r9, MILHAR_CRONOMETRO
    ldw r10, (r9)
    movia r11, code7seg
    add r11, r11, r10
    ldb r10, (r11)
    stbio r10, 3(r8)
    ret

code7seg:
.byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
#    0     1     2     3     4     5     6     7     8     9
