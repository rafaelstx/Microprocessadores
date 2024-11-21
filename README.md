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


# Projeto: Controle de LEDs, Animação e Cronômetro em Assembly

## Descrição

Este projeto implementa um sistema funcional para uma placa FPGA utilizando Assembly, com as seguintes funcionalidades principais:

- **Controle de LEDs**: Liga e desliga LEDs específicos com base em comandos recebidos via UART.
- **Animação com LEDs**: Executa uma animação visual em LEDs, controlada por switches.
- **Cronômetro**: Um cronômetro que exibe o tempo no display de 7 segmentos, podendo ser pausado e continuado por botões.
- **Interação via UART e Botões**: Recebe comandos via UART para controlar LEDs, animação e cronômetro, além de utilizar botões físicos para controle.

---

## Estrutura do Projeto

### 1. `main.s`
Este é o ponto de entrada do sistema. Ele configura os registradores iniciais, habilita interrupções, e realiza o loop principal do sistema:

- **Configuração Inicial**:
  - Configura o stack pointer.
  - Inicializa o temporizador para gerar interrupções periódicas.
  - Habilita interrupções de TIMER e botões no processador.
- **Loop Principal**:
  - Exibe uma mensagem inicial no terminal via UART.
  - Lê comandos enviados via UART.
  - Processa os comandos e executa funções relacionadas ao controle de LEDs, animação ou cronômetro.
- **Interrupções**:
  - Trata interrupções geradas pelo TIMER e botões.
  - Executa rotinas específicas para cada evento.

---

### 2. `led.s`
Controla o estado dos LEDs vermelhos com base em comandos enviados via UART.

- **Funcionamento**:
  - Lê o comando recebido via UART.
  - Identifica o LED a ser controlado e se a ação é ligar ou desligar.
  - Atualiza o estado dos LEDs no registrador correspondente.

- **Comandos**:
  - `00 xx`: Liga o LED de índice `xx`.
  - `01 xx`: Desliga o LED de índice `xx`.

---

### 3. `animacao.s`
Controla uma animação visual nos LEDs vermelhos, com base no estado dos switches.

- **Funcionamento**:
  - Lê o estado do SW0 para determinar a direção da animação:
    - **Para a Direita**: LEDs acendem sequencialmente da esquerda para a direita.
    - **Para a Esquerda**: LEDs acendem sequencialmente da direita para a esquerda.
  - Reinicia a animação quando todos os LEDs são desligados.

---

### 4. `cronometro.s`
Gerencia um cronômetro que exibe o tempo no display de 7 segmentos.

- **Funcionamento**:
  - Incrementa o cronômetro a cada ciclo (baseado no TIMER).
  - Atualiza os dígitos do cronômetro (unidade, dezena, centena e milhar).
  - Pausa e retoma o cronômetro com o pressionar de um botão.

- **Componentes**:
  - **`timer_control`**: Função que controla o fluxo do cronômetro e incrementa os ciclos.
  - **`button_control`**: Função que pausa ou retoma o cronômetro com base no estado dos botões.
  - **`update_display`**: Atualiza os dígitos do display de 7 segmentos com base no estado atual do cronômetro.

---

## Fluxo de Chamadas

1. **Inicialização**:
   - A `main.s` configura o ambiente inicial, habilita interrupções e entra no loop principal.

2. **Recepção de Comandos via UART**:
   - A `main.s` lê o comando no buffer.
   - O comando é processado e a função correspondente (`led_control`, `animation_control`, ou `timer_control`) é chamada.

3. **Interrupções**:
   - O TIMER ou os botões geram interrupções.
   - As rotinas `animation_control`, `timer_control` ou `button_control` são chamadas com base no tipo de evento.

4. **Controle de LEDs e Display**:
   - Os LEDs são atualizados diretamente em `led_control` ou `animation_control`.
   - O display de 7 segmentos é atualizado em `update_display`, dentro de `cronometro.s`.

---

## Funcionalidades

- **Comandos UART**:
  - `00 xx`: Liga o LED de índice `xx`.
  - `01 xx`: Desliga o LED de índice `xx`.
  - `10`: Inicia a animação.
  - `20`: Inicia o cronômetro.
  - `21`: Pausa o cronômetro.

- **Interação via Botões**:
  - Botão dedicado para pausar ou retomar o cronômetro.

- **Displays e LEDs**:
  - Os LEDs são atualizados em tempo real com base nos comandos ou na animação.
  - O display de 7 segmentos exibe o tempo atual do cronômetro.

---

## Requisitos do Sistema

- **Hardware**:
  - FPGA com suporte a:
    - UART.
    - Temporizador (TIMER).
    - LEDs vermelhos.
    - Switches e botões de pressão.
    - Display de 7 segmentos.

- **Software**:
  - Compilador e ambiente para Assembly (e.g., Quartus).

---

## Como Usar

1. **Carregue os Arquivos no FPGA**:
   - Compile e carregue os arquivos `main.s`, `led.s`, `cronometro.s`, e `animacao.s`.

2. **Envie Comandos via UART**:
   - Use um terminal UART para enviar comandos (e.g., `00 01` para ligar o LED 1).

3. **Interaja com os Botões e Switches**:
   - Use os botões para pausar/retomar o cronômetro.
   - Use os switches para controlar a direção da animação dos LEDs.

---

## Estrutura de Arquivos

- `main.s`: Configuração e fluxo principal.
- `led.s`: Controle de LEDs.
- `animacao.s`: Animação com LEDs.
- `cronometro.s`: Cronômetro e display de 7 segmentos.

