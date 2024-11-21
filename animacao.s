.equ TIMER_BASE,        0x10002000   # Endereço base do temporizador
.equ RED_LED_ADDR,      0x10000000   # Endereço dos LEDs vermelhos
.equ SWITCHES_ADDR,     0x10000040   # Endereço dos switches
.equ SWITCH_0_MASK,     0x01         # Máscara para SW0

.global animation_control

animation_control:
    # Salvar os registradores no stack frame
    addi sp, sp, -20                # Espaço para 5 registradores
    stw r8, 16(sp)
    stw r9, 12(sp)
    stw r10, 8(sp)
    stw r11, 4(sp)
    stw r12, 0(sp)

    # Verificar estado do SW0 para definir direção da animação
    movia r8, SWITCHES_ADDR         # Carregar endereço dos switches
    ldwio r9, 0(r8)                 # Ler estado dos switches
    andi r9, r9, SWITCH_0_MASK      # Isolar o estado do SW0
    beq r9, r0, animate_right       # Se SW0 está para baixo, animação para a direita
    br animate_left                 # Caso contrário, animação para a esquerda

animate_right:
    # Animação da esquerda para a direita
    movia r10, RED_LED_ADDR         # Endereço dos LEDs vermelhos
    ldwio r11, 0(r10)               # Ler estado atual dos LEDs
    beq r11, r0, init_left_led      # Se nenhum LED está aceso, iniciar no primeiro LED
    srli r11, r11, 1                # Shift para a direita
    beq r11, r0, init_left_led      # Se saiu da borda, reiniciar no primeiro LED
    br update_led                   # Atualizar o estado dos LEDs

init_left_led:
    movi r11, 1                     # Configurar primeiro LED (b0)

update_led:
    stwio r11, 0(r10)               # Atualizar estado dos LEDs
    br end_animation                # Encerrar a função

animate_left:
    # Animação da direita para a esquerda
    movia r10, RED_LED_ADDR         # Endereço dos LEDs vermelhos
    ldwio r11, 0(r10)               # Ler estado atual dos LEDs
    movia r12, 0b100000000000000000 # Máscara para o LED mais à esquerda
    beq r11, r0, init_right_led     # Se nenhum LED está aceso, iniciar no último LED
    slli r11, r11, 1                # Shift para a esquerda
    and r11, r11, r12               # Garantir que não exceda o LED mais à esquerda
    beq r11, r0, init_right_led     # Se saiu da borda, reiniciar no último LED
    br update_led                   # Atualizar o estado dos LEDs

init_right_led:
    movia r11, 0b100000000000000000 # Configurar último LED (b17)
    br update_led

end_animation:
    # Restaurar os registradores do stack frame
    ldw r8, 16(sp)
    ldw r9, 12(sp)
    ldw r10, 8(sp)
    ldw r11, 4(sp)
    ldw r12, 0(sp)
    addi sp, sp, 20                # Restaurar o stack
    ret                            # Retornar ao chamador
