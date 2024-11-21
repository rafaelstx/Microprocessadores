# Projeto de Microprocessadores

**2º semestre de 2024**

Este repositório contém o código e os materiais desenvolvidos para o projeto final da disciplina de Microprocessadores, realizado utilizando a placa DE2 Altera.

## Objetivo do Projeto

Desenvolver um aplicativo console que aceite comandos do usuário via comunicação UART, utilizando a janela terminal do programa **Altera Monitor**. O programa deverá interpretar os comandos e executar ações específicas na placa DE2, conforme descrito na tabela abaixo.

## Comandos Disponíveis

| Comando | Ação |
|---------|------|
| `00 xx` | Acender o xx-ésimo LED vermelho. |
| `01 xx` | Apagar o xx-ésimo LED vermelho. |
| `10`    | Iniciar animação com os LEDs vermelhos. A direção da animação é controlada pelo estado da chave `SW0`: se para baixo, a animação ocorre da esquerda para a direita; se para cima, da direita para a esquerda. Cada LED acende por 200 ms e depois apaga, repetindo o processo para todos os LEDs. |
| `11`    | Parar a animação dos LEDs. |
| `20`    | Iniciar um cronômetro de segundos utilizando os 4 displays de 7 segmentos. O botão `KEY1` controla a pausa ou retomada do cronômetro: - **Se a contagem está em andamento**, ela será pausada. - **Se está pausada**, ela será retomada. |
| `21`    | Cancelar o cronômetro. |

## Observações Importantes

O enunciado permite liberdade na definição de alguns comportamentos do sistema, tais como:

- O que acontece se um LED estiver aceso e o comando de animação for digitado?
- O cronômetro deve ser zerado ao ser pausado?

Essas definições foram especificadas no relatório do projeto e serão discutidas na apresentação final.

## Tecnologias e Recursos Utilizados

- **Placa DE2 Altera**
- **Linguagem de montagem do Nios II**
- **Ferramentas Altera Monitor**

## Como Usar

1. Conecte a placa DE2 ao computador e configure o ambiente UART.
2. Execute o programa no terminal utilizando o **Altera Monitor**.
3. Insira os comandos descritos na tabela e observe os resultados na placa.

## Relatório e Apresentação

O relatório completo será entregue ao professor e à turma ao final do semestre, detalhando as escolhas de implementação e os desafios enfrentados.


Estrutura Geral
O projeto é composto por quatro arquivos principais, cada um com responsabilidades específicas:

main.s: Ponto de entrada do programa. Gerencia interrupções, inicializações e fluxo de execução principal.
led.s: Controla os LEDs com base em comandos UART.
animacao.s: Executa a animação nos LEDs com base no estado do switch.
cronometro.s: Gerencia o cronômetro, incluindo contagem de tempo, exibição no display de 7 segmentos e interação com botões.
Funcionamento Geral
1. Inicialização
Na main.s:

Configura o stack pointer.
Habilita as interrupções no processador para:
Temporizador (TIMER): Para realizar eventos periódicos, como atualização do cronômetro.
Botões (PUSHBUTTON): Para interagir diretamente com as operações, como pausar o cronômetro.
Configura o temporizador para gerar interrupções a cada 1 segundo.
Exibe uma mensagem inicial no terminal via UART.
2. Interação com o Usuário
O usuário envia comandos pela UART.
Os comandos são analisados pela função process_command na main.s:
'0': Chama led_control para controlar os LEDs.
'1': Chama animation_control para iniciar a animação.
'2': Chama timer_control para ativar ou manipular o cronômetro.
3. Controle de LEDs (led.s)
Comando recebido:
'00': Liga o LED especificado.
'01': Desliga o LED especificado.
Processamento:
Lê o índice do LED a ser controlado com base nos caracteres do comando.
Manipula o estado do LED diretamente no registrador RED_LED_ADDR.
Execução:
Os LEDs são ativados ou desativados por manipulação de bits (OR para ligar, AND-NOT para desligar).
4. Animação com LEDs (animacao.s)
A animação é controlada por switches:
Se o SW0 está para baixo, os LEDs animam da esquerda para a direita.
Se o SW0 está para cima, os LEDs animam da direita para a esquerda.
Fluxo da Animação:
Verifica o estado dos LEDs atuais no registrador RED_LED_ADDR.
Atualiza o estado dos LEDs com deslocamentos para a esquerda ou direita.
Reinicia a animação ao alcançar as bordas.
A lógica é baseada em deslocamentos (shift left/right) e máscaras para limitar os LEDs ativos.
5. Cronômetro (cronometro.s)
O cronômetro é controlado por comandos UART e botões.
Comandos UART:
'20': Inicia o cronômetro.
'21': Reseta o cronômetro.
Botão:
Pausa ou continua a contagem.
Fluxo de Execução:
Contador de ciclos é incrementado a cada interrupção do TIMER.
A cada 5 ciclos (configuráveis), incrementa o cronômetro em 1 segundo.
O valor do cronômetro é armazenado em 4 registradores:
UNIDADE_CRONOMETRO
DEZENA_CRONOMETRO
CENTENA_CRONOMETRO
MILHAR_CRONOMETRO
O display de 7 segmentos é atualizado com base nos valores armazenados.
Quando o valor atinge 9, ocorre overflow para o próximo dígito.
6. Interrupções (main.s)
Interrupções do TIMER:
Chamam timer_control para manipular o cronômetro e verificar se o contador de ciclos deve ser ressetado.
Interrupções dos botões:
Chamam button_control para pausar ou retomar o cronômetro.
Fluxo de Chamadas
Ao iniciar o programa:
main.s:
Inicializa o sistema.
Configura TIMER e botões.
Exibe a mensagem inicial.
Ao receber um comando UART:
process_command na main.s:
'0': Chama led_control.
'1': Chama animation_control.
'2': Chama timer_control.
Interrupções:
TIMER:
Incrementa o contador de ciclos no cronômetro.
Atualiza o display a cada 5 ciclos.
Botões:
Pausa ou retoma o cronômetro.
O que o Projeto Faz
Recebe comandos UART:
Liga/desliga LEDs.
Inicia animações.
Controla um cronômetro.
Exibe informações no display de 7 segmentos:
Mostra o tempo contado pelo cronômetro.
Interação física com botões e switches:
Os botões pausam ou continuam o cronômetro.
Os switches definem a direção da animação.
Automatização com TIMER:
O TIMER gera eventos regulares para atualizar o estado do cronômetro.
Funcionalidades Conectadas
main.s gerencia o fluxo e direciona comandos para os módulos apropriados.
led.s lida com ações específicas para LEDs.
animacao.s controla padrões de iluminação nos LEDs.
cronometro.s gerencia o tempo e interage com botões e displays.
Essa arquitetura modular facilita a integração e a depuração, permitindo que cada módulo seja tratado de forma independente enquanto colabora no fluxo geral do programa.
