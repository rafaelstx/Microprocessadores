.equ UART_DATA_REG, 0x10001000       # Endereço do registro de dados do UART
.equ UART_CONTROL_REG, 0x10001004    # Endereço do registro de controle do UART
.equ TIMER_REG, 0x10002000           # Endereço do temporizador
.equ PUSHBUTTON_REG, 0x10000050      # Endereço do registro dos botões
.equ SWITCH_REG, 0x10000040          # Endereço dos switches
.equ LEDS_REG, 0x10000000            # Endereço dos LEDs
.equ STACK_BASE, 0x20000             # Endereço base para o stack pointer
.equ MAX_CMD_LENGTH, 8               # Comprimento máximo do comando

.org 0x20                            # Posição inicial do código
.global _start

_start:
    # Configurar o stack pointer para a base definida
    movia sp, STACK_BASE

    # Habilitar interrupções no processador
    movi r8, 0b11                    # Ativar IRQ0 e IRQ1 (TIMER e PUSHBUTTON)
    wrctl ienable, r8                # Escrever no registrador ienable
    movi r8, 1                       # Ativar interrupções no processador (PIE)
    wrctl status, r8

    # Configurar temporizador (TIMER)
    movia r8, TIMER_REG              # Carregar o endereço do temporizador
    movia r9, 50000000               # Configuração para 1 segundo (50 MHz)
    stwio r9, 8(r8)                  # Carregar o valor baixo do temporizador
    srli r9, r9, 16                  # Ajustar o valor para os 16 bits superiores
    stwio r9, 12(r8)                 # Carregar o valor alto do temporizador
    movi r10, 7                      # Ativar o TIMER (ITO, CONT)
    stwio r10, 4(r8)                 # Escrever no registrador de controle do TIMER

    # Imprimir mensagem inicial para o usuário
    call print_message

main_loop:
    # Ler comando do usuário via UART
    call read_uart
    # Processar o comando recebido
    call process_command
    # Repetir o loop
    br main_loop

# Função para imprimir a mensagem inicial
print_message:
    movia r4, INIT_MSG               # Carregar a mensagem inicial na memória
    call uart_write_string           # Chamar função para escrever a string no UART
    ret                              # Retornar

# Função para ler o comando via UART
read_uart:
    movia r4, CMD_BUFFER             # Endereço inicial do buffer de comando
    movi r5, MAX_CMD_LENGTH          # Limite máximo do comando
    call uart_read_string            # Chamar função para leitura do UART
    ret                              # Retornar

# Função para processar o comando lido
process_command:
    movia r8, CMD_BUFFER             # Carregar o buffer de comando
    ldb r9, (r8)                     # Ler o primeiro caractere do comando

    # Comparar o primeiro caractere e redirecionar

    # Substituição de `cmpnei r9, '0'`
    subi r10, r9, '0'                # Subtrai '0' do valor em r9
    bne r10, r0, check_animation     # Se r9 não for igual a '0', verificar o próximo

    # Comando de LED
    call cmd_led
    br main_loop                     # Retornar ao loop principal

check_animation:
    # Substituição de `cmpnei r9, '1'`
    subi r10, r9, '1'                # Subtrai '1' do valor em r9
    bne r10, r0, check_timer         # Se r9 não for igual a '1', verificar o próximo

    # Comando de Animação
    call cmd_animation
    br main_loop                     # Retornar ao loop principal

check_timer:
    # Substituição de `cmpnei r9, '2'`
    subi r10, r9, '2'                # Subtrai '2' do valor em r9
    bne r10, r0, invalid_command     # Se r9 não for igual a '2', comando inválido

    # Comando de Cronômetro
    call cmd_timer
    br main_loop                     # Retornar ao loop principal

invalid_command:
    # Se o comando for inválido, reiniciar o loop principal
    br main_loop

cmd_led:
    call led_control                 # Chamar a função para controlar LEDs
    ret                              # Retornar ao loop principal

cmd_animation:
    call animation_control           # Chamar a função para animações
    ret                              # Retornar ao loop principal

cmd_timer:
    call timer_control               # Chamar a função para o cronômetro
    ret                              # Retornar ao loop principal

# Funções UART

# Função para enviar uma string via UART
uart_write_string:
    movia r10, UART_DATA_REG         # Endereço do registrador de dados do UART
write_loop:
    ldb r8, 0(r4)                    # Ler o próximo caractere da string
    beq r8, r0, write_end            # Se for o caractere nulo (fim), sair do loop
    stbio r8, 0(r10)                 # Enviar o caractere via UART
    addi r4, r4, 1                   # Avançar para o próximo caractere
    br write_loop                    # Repetir o loop
write_end:
    ret                              # Retornar

# Função para ler uma string via UART
uart_read_string:
    movia r10, UART_DATA_REG         # Endereço do registrador de dados do UART
    movia r11, UART_CONTROL_REG      # Endereço do registrador de controle do UART
    movi r9, 0                       # Contador para caracteres lidos
read_loop:
    ldwio r12, 0(r11)                # Ler o status do UART
    andi r13, r12, 0x8000            # Verificar o bit RVALID (dado disponível)
    beq r13, r0, read_loop           # Se não houver dado, continuar esperando
    ldwio r12, 0(r10)                # Ler o dado do UART
    stb r12, 0(r4)                   # Salvar o dado no buffer
    addi r4, r4, 1                   # Avançar no buffer
    subi r5, r5, 1                   # Reduzir o contador de caracteres restantes
    movi r13, 0x0A                   # Carregar o valor 0x0A (ENTER)
    beq r12, r13, read_end           # Se o caractere for ENTER, encerrar
    bne r5, r0, read_loop            # Continuar lendo até o limite
read_end:
    stb r0, 0(r4)                    # Adicionar null terminator no buffer
    ret                              # Retornar

# Dados para mensagem inicial e buffer
.org 0x300
CMD_BUFFER:
    .skip MAX_CMD_LENGTH             # Reservar espaço para o buffer de comando

INIT_MSG:
    .asciz "Digite o comando (ex: 00 xx):\n" # Mensagem inicial exibida ao usuário
