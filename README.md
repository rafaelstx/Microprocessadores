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
