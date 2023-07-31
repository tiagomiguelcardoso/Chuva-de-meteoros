; *********************************************************************************
; * IST1103561
; * TIAGO CARDOSO
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DEFINE_LINHA    			EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   			EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    			EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     			EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 				EQU 6002H      		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  	EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
APAGA_CENARIO_FRONTAL		EQU 6044H	   ; apaga cenario frontal
SELECIONA_CENARIO_FRONTAl	EQU 6046H	   ; endereço do comando para selecionar uma imagem frontal
DISPLAYS					EQU  0A000H	; endereço do periférico que liga aos displays
TEC_LIN						EQU  0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL						EQU  0E000H	; endereço das colunas do teclado (periférico PIN)
TOCA_SOM					EQU 605AH      ; endereço do comando para tocar um som

MASCARA						EQU	0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado


; Cada tecla é composta por 2 digitos AB onde A é o numero da linha de 1 a 8 (1|2|4|8) e B é o numero da coluna
; Apesar o teclado ler qualquer tecla, estas são as unicas necessarias para correr todas as funcionalidades do programa
TECLA_0			EQU 	11
TECLA_1			EQU 	12		
TECLA_2			EQU 	14			
TECLA_C			EQU		81
TECLA_D			EQU		82
TECLA_E			EQU		84

; Constantes de numeros
ZERO 				EQU     0
UM 					EQU		1
DOIS				EQU		2
TRES				EQU		3
QUATRO				EQU		4
CINCO 				EQU 	5
DEZ 				EQU		10
DEZASSEIS 			EQU     16
CEM  				EQU 	100
DOIS_CINCO_SEIS 	EQU		256


LINHA        		EQU  28        	; linha do rover 

MAX_LINHA_TERRA		EQU  28			; maximo que um meteorito pode ir sem chocar com a terra
MAX_LINHA_ROVER		EQU	 24			; maximo que um meteorito pode ir antes de poder chocar com o rover
MIN_COLUNA			EQU  0			; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA			EQU  63        	; número da coluna mais à direita que o objeto pode ocupar

LARGURA			EQU	5			; largura do rover
CINZENTO		EQU	0FCCCH		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
VERDE			EQU 0F0C0H		; cor verde
AZUL			EQU 0F06CH		; cor azul
VERMELHO		EQU	0FF00H		; cor vermelho
ROXO			EQU	0F96CH		; cor roxo
AMARELO			EQU 0FFF0H		; cor amerelo

ATRASO					EQU	0D00H		; atraso para limitar a velocidade de movimento do rover

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H

; Reserva do espaço para as pilhas dos processos
	STACK 200H			; espaço reservado para a pilha do processo "programa principal"
SP_inicial_prog_princ:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 200H			; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:			; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 200H			; espaço reservado para a pilha do processo "rover"
SP_inicial_rover:			; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 200H			; espaço reservado para a pilha do processo "display"
SP_inicial_display:			; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 200H			; espaço reservado para a pilha do processo "missil"
SP_inicial_missil:			; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 200H			; espaço reservado para a pilha do processo "colisao"
SP_inicial_colisao:		; este é o endereço com que o SP deste processo deve ser inicializado
	
	STACK 200H			; espaço reservado para a pilha do processo "processo"
SP_inicial_processo:		; este é o endereço com que o SP deste processo deve ser inicializado
	
	STACK 200H			; espaço reservado para a pilha do processo "energia"
SP_inicial_energia:		; este é o endereço com que o SP deste processo deve ser inicializado
	
; Locks
tecla_carregada:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
						; uma vez por cada tecla carregada
							
tecla_continuo:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
						; enquanto a tecla estiver carregada
							


COLUNA:			WORD  30        ; coluna do rover (a meio do ecrã)

DEF_ROVER:						; tabela que define o rover (cor, largura, pixels)
	WORD        5				; largura do rover
	WORD		4				; altura do rover

	WORD  		0, 0, AMARELO, 0, 0
	WORD		AMARELO, 0, AMARELO, 0, AMARELO
	WORD		AMARELO, AMARELO, AMARELO, AMARELO, AMARELO
	WORD		0, AMARELO, 0, AMARELO, 0
	
INFO_METEORITO:					; informaçao sobre o meteorito a tratar
	WORD		-1				; linha  		| nunca será usado, é so para iniciar a variavel
	WORD		10				; coluna		| nunca será usado, é so para iniciar a variavel
	WORD        1				; tipo de meteorito:  0 - MAU | 1 - BOM

DEF_METEORITO_BOM:
	WORD		DEF_METEORITO_1
	WORD		DEF_METEORITO_2
	WORD		DEF_METEORITO_BOM_3
	WORD		DEF_METEORITO_BOM_4
	WORD		DEF_METEORITO_BOM_5

DEF_METEORITO_MAU:
	WORD		DEF_METEORITO_1
	WORD		DEF_METEORITO_2
	WORD		DEF_METEORITO_MAU_3
	WORD		DEF_METEORITO_MAU_4
	WORD		DEF_METEORITO_MAU_5

DEF_METEORITO_1:
	WORD		1				; largura do meteorito
	WORD		1				; altura do meteorito
	WORD		CINZENTO

DEF_METEORITO_2:
	WORD		2				; largura do meteorito
	WORD		2				; altura do meteorito
	WORD		CINZENTO, CINZENTO
	WORD		CINZENTO, CINZENTO

DEF_METEORITO_BOM_3:
	WORD		3				; largura do meteorito
	WORD		3				; altura do meteorito
	WORD		0, VERDE, 0
	WORD		VERDE, VERDE, VERDE
	WORD		0, VERDE, 0

DEF_METEORITO_BOM_4:
	WORD		4				; largura do meteorito
	WORD		4				; altura do meteorito
	WORD		0, VERDE, VERDE, 0
	WORD		VERDE, VERDE, VERDE, VERDE
	WORD		VERDE, VERDE, VERDE, VERDE
	WORD		0, VERDE, VERDE, 0

DEF_METEORITO_BOM_5:			
	WORD        5				; largura do meteorito
	WORD 		5				; altura do meteorito
	WORD		0, VERDE, VERDE, VERDE, 0
	WORD		VERDE, VERDE, VERDE, VERDE, VERDE
	WORD		VERDE, VERDE, VERDE, VERDE, VERDE
	WORD		VERDE, VERDE, VERDE, VERDE, VERDE
	WORD		0, VERDE, VERDE, VERDE, 0

DEF_METEORITO_MAU_3:
	WORD		3				; largura do meteorito
	WORD		3				; altura do meteorito
	WORD		VERMELHO, 0, VERMELHO
	WORD		0, VERMELHO, 0
	WORD		VERMELHO, 0, VERMELHO

DEF_METEORITO_MAU_4:
	WORD		4				; largura do meteorito
	WORD		4				; altura do meteorito
	WORD		VERMELHO, 0, 0, VERMELHO
	WORD		VERMELHO, 0, 0, VERMELHO
	WORD		0, VERMELHO, VERMELHO, 0
	WORD		VERMELHO, 0, 0, VERMELHO

DEF_METEORITO_MAU_5:			; tabela que define o meteorito 
	WORD        5				; largura do meteorito
	WORD 		5				; altura do meteorito
	WORD		VERMELHO, 0 , 0, 0, VERMELHO
	WORD		VERMELHO, 0, VERMELHO, 0, VERMELHO
	WORD		0, VERMELHO, VERMELHO, VERMELHO, 0
	WORD		VERMELHO, 0, VERMELHO, 0, VERMELHO
	WORD		VERMELHO, 0 , 0, 0, VERMELHO


INFO_MISSIL:
	WORD 		0					; se está ativo ou não
	WORD 		27					; linha do missil
	WORD 		30					; coluna do missil

DEF_MISSIL:
	WORD		1					; largura do missil
	WORD		1					; altura do missil
	WORD		ROXO				; cor do missil


ENERGIA:		WORD		CEM		; guarda o valor do display

RANDOM: 		WORD 0 				; numero random entre 1 e 8

tab:
	WORD int_meteorito				; rotina de atendimento da interrupçao 0
	WORD int_missil					; rotina de atendimento da interrupçao 1
	WORD int_energia				; rotina de atendimento da interrupçao 2


; Variaveis relativas ao teclado
TECLA: 				WORD 	0		; tecla que foi pressionada
LINHA_TECLADO:		WORD 	1		; guarda o numero da linha a ser testada

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     		; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial_prog_princ		; inicializa SP do programa principal
	MOV  BTE, tab					; inicializa BTE (registo de Base da Tabela de Exce��es)
    MOV  [APAGA_AVISO], R1			; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1			; apaga todos os pixels já desenhados (o valor de R1 não é relevante)

	MOV	R1, 0						; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FRONTAl], R1	; seleciona o cenário frontal
	MOV	R7, 1						; valor a somar à coluna do rover, para o movimentar
	CALL	teclado					; cria o processo teclado
pre_jogo:
	MOV R2, ENERGIA					; corre o ciclo até ser pressionada a tecla C
	MOV R3, CEM
	MOV [R2], R3
	MOV	R1, [tecla_carregada]
	MOV R1, [TECLA]
	MOV R4, TECLA_C
	CMP	R1, R4
    JNZ pre_jogo

	MOV  [APAGA_ECRÃ], R1					; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV		R1, 1							; cenário de fundo número 0
	MOV  [APAGA_CENARIO_FRONTAL], R1      	; apaga cenario frontal
    MOV  [SELECIONA_CENARIO_FUNDO], R1		; seleciona o cenário de fundo
	CALL reiniciar_variaveis				; sempre que o jogo reiniciar ativa
     
	EI2					; permite interrupções 2
	EI1					; permite interrupções 1
	EI0					; permite interrupções 0
	EI					; permite interrupções (geral)

	; cria processos. O CALL não invoca a rotina, apenas cria um processo executável
	
	CALL	rover					; cria o processo rover
	CALL	atualiza_display 		; cria o processo atualiza_display
	CALL 	missil					; cria o processo missil
	CALL 	colisao					; cria o processo colisao
	CALL 	processo				; cria o processo "processo"
	CALL  	energia					; cria o processo energia


; **********************************************************************
; Processo
;
; DISPLAY - Processo que atualiza o display
;
; **********************************************************************

PROCESS SP_inicial_display			; indicação de que a rotina que se segue é um processo,
									; com indicação do valor para inicializar o SP
atualiza_display:
	YIELD
	MOV  R2, [ENERGIA]				; valor do contador, cujo valor vai ser mostrado nos displays
	CALL controlo_de_energia
	MOV  R0, DISPLAYS        		; endereço do periférico que liga aos displays
	MOV R3, R2						; registo com o numero
	MOV R4, R2						; outro registo com o numero
	MOV R8, CEM						; R5 = 100
	MOV R9, 10	
	DIV R3, R8						; R3 - numero na casa das centenas 
	MOD R4, R8						; R4 - resto
	MOV R5, R4
	DIV R4, R9						; R4 - numero na casa das dezenas 
	MOD R5, R9						; resto
	MOV R8, DOIS_CINCO_SEIS			; 256
	MOV R9, DEZASSEIS				; 16
;   R3 * 256 + R4 * 16 + R5
	MUL R3, R8						; R3 * 256
	MUL R4, R9						; R4 * 16
	ADD R3, R4						
	ADD R3, R5						
	MOV [R0], R3
	JMP atualiza_display

; multiplicar por 256 e 16 + resto
	MOV [R0], R2            		; mostra o valor do contador nos displays
	JMP atualiza_display

controlo_de_energia:				; repoe a energia a 100 caso ultrapasse
	PUSH R1
	PUSH R2
	PUSH R3
	MOV  R1, ENERGIA				; endereço do contador
	MOV R2, [R1]
	MOV R3, CEM
	CMP R2, R3
	JLE controlo_de_energia_final	; passa à frente caso a energia seja menor que 100

energia_100:						; altera o valor para 100
	MOV [R1], R3

controlo_de_energia_final:
	POP R3
	POP R2
	POP R1
	RET

; **********************************************************************
; Processo
;
; TECLADO - Processo que deteta quando se carrega numa tecla na 4ª linha
;		  do teclado e escreve o valor da coluna num LOCK.
;
; **********************************************************************

PROCESS SP_inicial_teclado		; indicação de que a rotina que se segue é um processo,
								; com indicação do valor para inicializar o SP
teclado:						; processo que implementa o comportamento do teclado
	MOV  R2, TEC_LIN			; endereço do periférico das linhas
	MOV  R3, TEC_COL			; endereço do periférico das colunas
	MOV  R5, MASCARA			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

espera_tecla:					; neste ciclo espera-se até uma tecla ser premida
	YIELD						; este ciclo é potencialmente bloqueante, pelo que tem de
								; ter um ponto de fuga (aqui pode comutar para outro processo)

	CALL nova_linha
	MOV  R1, [LINHA_TECLADO]	; testar a linha 4
	MOVB [R2], R1				; escrever no periférico de saída (linhas)
	MOVB R0, [R3]				; ler do periférico de entrada (colunas)
	AND  R0, R5					; elimina bits para além dos bits 0-3
	CMP  R0, 0					; há tecla premida?
	JZ   espera_tecla			; se nenhuma tecla premida, repete
	
	CALL conversor
	MOV	[tecla_carregada], R0	; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada
								; (o valor escrito é o número da coluna da tecla no teclado)

ha_tecla:						; neste ciclo espera-se até NENHUMA tecla estar premida
	YIELD						; este ciclo é potencialmente bloqueante, pelo que tem de
								; ter um ponto de fuga (aqui pode comutar para outro processo)

	MOV	[tecla_continuo], R0	; informa quem estiver bloqueado neste LOCK que uma tecla está a ser carregada
								; (o valor escrito é o número da coluna da tecla no teclado)
     MOVB [R2], R1				; escrever no periférico de saída (linhas)
     MOVB R0, [R3]				; ler do periférico de entrada (colunas)
	AND  R0, R5					; elimina bits para além dos bits 0-3
     CMP  R0, 0					; há tecla premida?
     JNZ  ha_tecla				; se ainda houver uma tecla premida, espera até não haver

	JMP	espera_tecla			; esta "rotina" nunca retorna porque nunca termina
								; Se se quisesse terminar o processo, era deixar o processo chegar a um RET

nova_linha:						; muda a Linha a testar a seguir
	PUSH R6
	PUSH R7
	PUSH R8
    MOV R7, DEZASSEIS
	MOV R6 ,LINHA_TECLADO
	MOV R8 , [R6]
	ADD R8, R8	
	MOV [R6], R8
	CMP R8, R7
    JNZ nova_linha2

linha_um:						; reinicia a linha a testar para 1
	PUSH R1
	PUSH R2
	MOV  R2 , UM
	MOV R1, LINHA_TECLADO
    MOV [R1], R2
	POP R2
	POP R1

nova_linha2:					; apenas para dar os POPs
	POP R8
	POP R7
	POP R6
    RET

conversor:						; converter a linha (L) e a coluna (C) num numero  LC
	PUSH R2
	PUSH R3
	MOV R2, [LINHA_TECLADO]
	MOV R3, 10
    MUL R3, R2
	ADD R3, R0
	MOV R2, TECLA
    MOV [R2], R3
	POP R3
	POP R2
	RET

; **********************************************************************
; Processo
;
; rover - Processo que desenha um rover e o move horizontalmente, com
;		 temporização marcada pela interrupção 0
;
; **********************************************************************

PROCESS SP_inicial_rover		; indicação de que a rotina que se segue é um processo,
								; com indicação do valor para inicializar o SP
rover:							; processo que implementa o comportamento do rover
								; desenha o rover na sua posição inicial
    MOV R1, LINHA				; linha do rover
	MOV	R4, DEF_ROVER			; endereço da tabela que define o rover
ciclo_rover:
	MOV R2, [COLUNA]
	MOV R10, 1
	MOV [TOCA_SOM], R10			; som do movimento
	CALL	desenha_boneco		; desenha o rover a partir da tabela
espera_movimento:
	MOV	R3, [tecla_continuo]	; lê o LOCK e bloqueia até o teclado escrever nele novamente
	MOV R3, [TECLA]
	MOV R5, TECLA_0
	CMP	R3, R5					; é a coluna da tecla 0?
	JZ	move_esquerda			; se não é, ignora e continua à espera
	MOV R5, TECLA_2				; é a coluna da tecla 2?
	CMP R3, R5
	JZ 	move_direita			
	JMP espera_movimento		; se não vai nem para a esquerda nem para a direita

move_esquerda:					
	MOV R7, -1
	JMP ha_movimento
move_direita:
	MOV R7, +1
	JMP ha_movimento

ha_movimento:
	CALL	apaga_boneco			; apaga o rover na sua posição corrente
	MOV	R6, [R4]					; obtém a largura do rover
	CALL	testa_limites			; vê se chegou aos limites do ecrã e nesse caso inverte o sentido
	MOV R9, COLUNA
	MOV R8, [COLUNA]
	ADD	R8, R7						; para desenhar objeto na coluna seguinte (direita ou esquerda)
	MOV [R9], R8
	JMP	ciclo_rover					; esta "rotina" nunca retorna porque nunca termina
									; Se se quisesse terminar o processo, era deixar o processo chegar a um RET

; **********************************************************************
; METEORITO - Processo referente a apagr e desenhar um meteorito
; 
;  Tambem contem outras rotinas referentes ao meteorito
; **********************************************************************

; colocar isto como um processo 

int_meteorito:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	MOV R3, INFO_METEORITO
	MOV R1, [R3]								; linha do meteorito
	ADD R3, DOIS
	MOV R2, [R3]								; coluna do meteorito
	CALL estrutura_meteorito					; estrutura que que vai ser apagada
	CALL apaga_boneco
	MOV R3, INFO_METEORITO
	ADD R1, 1
	MOV [R3], R1
	CALL estrutura_meteorito					; estrutura que vai ser desenhada
	CALL desenha_boneco
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RFE

estrutura_meteorito:								; devolve R4 que é o endereço do meteorito
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
	PUSH R6
	PUSH R7
	CALL numero_meteorito
	MOV R6, INFO_METEORITO
	ADD R6, QUATRO
	MOV R6, [R6]
	MOV R7, 1
	CMP R6, R7
	JZ e_mbom
	JMP e_mmau

e_mbom:												;  é meteorito bom, por isso vai procurar a estrutura nos DEF_METEORITO_BOM
	MOV R5, DEF_METEORITO_BOM
	JMP estrutura_meteorito_final

e_mmau:
	MOV R5, DEF_METEORITO_MAU						;  é meteorito mau, por isso vai procurar a estrutura nos DEF_METEORITO_MAU
	JMP estrutura_meteorito_final

estrutura_meteorito_final:
	ADD R5, R3
	MOV R4, [R5]
	POP R7
	POP R6
	POP R5
	POP R3
	POP R2
	POP R1
	RET

numero_meteorito:       ; é baseado na linha que vai ser escrita
	PUSH R8
	MOV R8, 3
    CMP R1, R8
    JLE m_1
	MOV R8, 6
    CMP R1, R8
    JLE m_2
	MOV R8, 9
    CMP R1, R8
    JLE m_3
	MOV R8, 12
    CMP R1, R8
    JLE m_4
    JMP m_5

m_1:
	MOV R3, 0
	JMP numero_meteorito_final
m_2:
	MOV R3, 2
	JMP numero_meteorito_final
m_3:
	MOV R3, 4
	JMP numero_meteorito_final
m_4:
	MOV R3, 6
	JMP numero_meteorito_final
m_5:
	MOV R3, 8
	JMP numero_meteorito_final

numero_meteorito_final:					; devolve R3 para a estrura_meteorito, 
	POP R8								; que é para saber quanto adicionar ao endereço com os meteoritos
	RET
 
; **********************************************************************
; DESENHA_BONECO - Desenha um rover na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************

desenha_boneco:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4    			
	PUSH R5
	PUSH R6
	PUSH R8
	PUSH R9
	MOV	R6, R2			; cópia da coluna do boneco
	MOV	R5, [R4]		; obtém a largura do boneco
	MOV R9, R5			; manter uma constante com a largura
	ADD	R4, 2
	MOV R8, [R4]		; obtém a altura do rover
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
	CALL desenha_linha
	POP R9
	POP R8
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET	

desenha_linha:
	CMP R8, 0               	; se for 0 acaba
	JNZ desenha_pixels
	RET		

desenha_pixels:       			; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]				; obtém a cor do próximo boneco do rover
	CALL escreve_pixel
	ADD	R4, 2					; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
     ADD  R6, 1               	; próxima coluna
     SUB  R5, 1					; menos uma coluna para tratar
     JNZ  desenha_pixels      	; continua até percorrer toda a largura do objeto
	ADD R1, 1					; proximo linha
	SUB R8, 1					; menos uma linha para tratar
	MOV R6, R2					; reinicia a coluna a fazer
	MOV	R5, R9					; largura do boneco
	JMP desenha_linha

; **********************************************************************
; APAGA_BONECO - Apaga um rover na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************

apaga_boneco:       			; desenha o boneco a partir da tabela
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R8
	PUSH R9
	MOV	R6, R2			; cópia da coluna do boneco
	MOV	R5, [R4]				; obtém a largura do boneco
	MOV R9, R5					; manter uma constante com a largura
	ADD	R4, 2
	MOV R8, [R4]            	; altura do boneco
	CALL apaga_linha
	POP R9
	POP R8
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET

apaga_linha:
	CMP R8, 0               	; se for 0 acaba
	JNZ apaga_pixels
	RET 						; caso contrario continua	

apaga_pixels:       			; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0					; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel
     ADD  R6, 1             	; próxima coluna
     SUB  R5, 1					; menos uma coluna para tratar
     JNZ  apaga_pixels    		; continua até percorrer toda a largura do objeto
	MOV	R11, ATRASO				; atraso para limitar a velocidade de movimento do boneco
	CALL atraso
	ADD R1, 1					; proximo linha
	SUB R8, 1					; menos uma linha para tratar
	MOV R6, R2					; reinicia a coluna a fazer
	MOV	R5, R9					; largura do boneco
	JMP apaga_linha

atraso:							; adiciona atraso ao programa
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET

; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R6		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; TESTA_LIMITES - Testa se o rover chegou aos limites do ecrã e nesse caso
;			   inverte o sentido de movimento
;
; **********************************************************************
testa_limites:
	PUSH	R5
	PUSH	R6
	MOV R2, [COLUNA]
	CMP R7, -1
	JZ testa_limite_esquerdo
	CMP R7, 1
	JZ testa_limite_direito

testa_limite_esquerdo:		; vê se o rover chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JZ impede_movimento
	JMP	sai_testa_limites	; entre limites. Mantém o valor do R7

testa_limite_direito:		; vê se o rover chegou ao limite direito
	ADD	R6, R2				; posição a seguir ao extremo direito do rover
	MOV	R5, MAX_COLUNA		
	SUB R6, 1				; retira um pois a coluna já é um pixel da largura
	CMP	R6, R5				; verifica se o rover atual já está no limite
	JZ impede_movimento
	JMP	sai_testa_limites	; entre limites. Mantém o valor do R7

impede_movimento:
	MOV	R7, 0

sai_testa_limites:	
	POP	R6
	POP	R5
	RET

; **********************************************************************
; RANDOM - Escreve no endereço de RANDOM um numero aleatorio
;			   
; **********************************************************************

random:
	PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
	PUSH R6
    PUSH R7
    PUSH R8

    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas

; ao usarmos o MOVB conseguimos que os valores sejam entre 0000H e 00F0H, permitindo apenas 16 digitos na segunda casa.
; assim, dividindo por 2 conseguimos 8 casos que é o range de numeros que queremos obter

ciclo_random:
    MOV  R1, 4         ; testar a linha 4 
    MOVB [R2], R1      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
    MOV R7, 0
    MOV R8, 0010H
    CMP R0, R8
    JLE n_um
    MOV R8, 0030H
    CMP R0, R8
    JLE n_dois
    MOV R8, 0050H
    CMP R0, R8
    JLE n_tres
    MOV R8, 0070H
    CMP R0, R8
    JLE n_quatro
    MOV R8, 0090H
    CMP R0, R8
    JLE n_cinco
    MOV R8, 00B0H
    CMP R0, R8
    JLE n_seis
    MOV R8, 00D0H
    CMP R0, R8
    JLE n_sete
    MOV R8, 00F0H
    CMP R0, R8
    JLE n_oito

n_um:
    MOV R7, 1
    JMP random_final
n_dois:
    MOV R7, 2
    JMP random_final
n_tres:
    MOV R7, 3
    JMP random_final
n_quatro:
    MOV R7, 4
    JMP random_final
n_cinco:
    MOV R7, 5
    JMP random_final
n_seis:
    MOV R7, 6
    JMP random_final
n_sete:
    MOV R7, 7
    JMP random_final
n_oito:
    MOV R7, 8
    JMP random_final

random_final:
    MOV R6, RANDOM
    MOV [R6], R7

    POP R8
    POP R7
	POP R6	
    POP R3
    POP R2
    POP R1
	POP R0
    RET



; interrupçao que diminui a energia de 3 em 3 segundos por 5%
int_energia:
	PUSH R1
	PUSH R2
	MOV  R0, DISPLAYS        		; endereço do periférico que liga aos displays
	MOV R1, ENERGIA
	MOV R2, [R1]
	SUB R2, CINCO
	MOV [R1], R2
	MOV [R0], R2
	POP R2
	POP R1
	RFE



; rotinha que gera as informaçoes para um novo meteorito começando na linha 0
gera_novo_meteorito:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	MOV R1, INFO_METEORITO
	MOV R3, 0
	MOV [R1], R3
	CALL random
	MOV R4, [RANDOM]
	MOV R8, 7
	MUL R4, R8
	ADD R1, 2
	MOV [R1], R4
	ADD R1, 2
	CALL random
	MOV R5, [RANDOM]
	MOV R6, 2
	CMP R5, R6
	JLE gera_bom
	JMP gera_mau
gera_bom:
	MOV R7, 1
	MOV [R1], R7
	JMP gera_novo_meteorito_final
gera_mau:
	MOV R7, 0
	MOV [R1], R7
gera_novo_meteorito_final:
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET


; **********************************************************************
; METEORITO - Processo referente a criar um missil novo
; 
; **********************************************************************

PROCESS SP_inicial_missil

missil:
	YIELD
	MOV	R1, [tecla_carregada]
	MOV R1, [TECLA]
	MOV R4, TECLA_1
	CMP	R1, R4						; é a coluna da tecla 1?
	JZ cria_missil
	JMP missil

cria_missil:
	MOV R3, INFO_MISSIL
	MOV R7, [R3]
	MOV R8, 0
	CMP R7, R8
	JNZ missil
	MOV R5, [COLUNA] 
	ADD R5, 2					
	MOV R1, 27
	MOV R2, R5
	MOV R4, DEF_MISSIL
	MOV R6, UM
	MOV [R3], R6
	ADD R3, 2
	MOV [R3], R1
	ADD R3, 2
	MOV [R3], R2
	MOV R10, 2
	MOV [TOCA_SOM], R10
	CALL desenha_boneco
	MOV R3, ENERGIA
	MOV R5, [R3]
	MOV R6, CINCO
	SUB R5, R6
	MOV [R3], R5
	JMP missil


; interrupçao que move o missil 2 unidades de cada vez
int_missil:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	MOV R3, INFO_MISSIL
	MOV R6, UM
	MOV R5, R6
	MOV R6, [R3]
	CMP R5, R6						; verificar se o missil está ativo
	JZ avançar_missil
	JMP int_missil_final

avançar_missil:
	ADD R3, 2
	MOV R1, [R3]

	ADD R3, 2
	MOV R2, [R3]
	MOV R4, DEF_MISSIL
	CALL apaga_boneco

	MOV R6, 5                      ; distancia maxima que pode percorrer	(PIXEL onde pode chegar)
	CMP R1, R6
	JLE dm
	SUB R1, 2
	SUB R3, 2
	MOV [R3], R1
	CALL desenha_boneco
	JMP int_missil_final

dm:									; destroi o missil
	CALL destroi_missil
	JMP int_missil_final

destroi_missil:
	PUSH R1
	PUSH R2
	MOV R1, INFO_MISSIL
	MOV R2, 0
	MOV [R1], R2
	POP R2
	POP R1
	RET

int_missil_final:					; serve apenas para os POPs e os returns
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RFE

; **********************************************************************
; Colisao - Verifica se houve colisao com os meteoritos
; 
; **********************************************************************
PROCESS SP_inicial_colisao

colisao:
	YIELD
	MOV R3, INFO_METEORITO
	MOV R1, [R3]								; linha do meteorito
	ADD R3, DOIS
	MOV R2, [R3]								; coluna do meteorito
	CALL embate_missil
	MOV R5, MAX_LINHA_TERRA						; linha para atingir o planeta
	CMP R5, R1
	JZ embate_planeta							; verifica se bateu num planeta
	MOV R5, MAX_LINHA_ROVER						; linha onde pode atingir o rover
	CMP R5, R1
	JLE embate_rover							; verifica se bateu no rover
	JMP colisao      							; ERRADO MUDAR ############

embate_planeta:
	MOV R10, 0
	MOV [TOCA_SOM], R10
	CALL estrutura_meteorito					; estrutura que vai ser apagada
	CALL apaga_boneco							; apaga o meteorito que bateu
	CALL gera_novo_meteorito					; gera outro meteorito 
	MOV R3, INFO_METEORITO
	MOV R1, [R3]								; linha do meteorito
	ADD R3, DOIS
	MOV R2, [R3]								; coluna do meteorito	
	CALL estrutura_meteorito					; estrutura do novo meteorito
	CALL desenha_boneco							; desenha o novo meteorito
	JMP colisao
	

embate_rover:
	PUSH R1 						; variavel de uso
	PUSH R2							; variavel de uso
	PUSH R3							; X top left 		do rover    
	PUSH R4							; Y top left 		do rover
	PUSH R5							; X bottom right 	do rover	
	PUSH R6							; Y bottom right 	do rover
	PUSH R7							; X top left 		do meteorito
	PUSH R8							; Y top left 		do meteorito
	PUSH R9							; X bottom right 	do meteorito
	PUSH R10						; Y bottom right 	do meteorito
	PUSH R11						; variavel de uso | embate depois da rotina

	; METEORITO ( primeiro porque precisamos de R4)

	MOV R11, INFO_METEORITO
	MOV R1, [R11]				; linha do meteorito
	ADD R11, DOIS
	MOV R2, [R11]				; coluna do meteorito
	CALL estrutura_meteorito	; devolve R4 com a estrutura do meteorito
	MOV R8, R1					; numero da linha que é a coordenada mais acima
	MOV R7, R2					; numero da coluna que é a coordenada mais à esquerda
	MOV R1, [R4]				; largura do meteorito
	ADD R4, DOIS
	MOV R2, [R4]				; altura do meteorito
	SUB R1, UM					; - 1 porque a coordenada ocupa espaço
	SUB R2, UM					; - 1 porque a coordenada ocupa espaço
	ADD R1, R8					; soma a linha com a altura
	ADD R2, R7					; soma a coluna com a largura 
	MOV R9, R2					; numero da coluna que é a coordenada mais à direita
	MOV R10, R1					; numero da linha que é a coordenada mais a baixo

	; ROVER
	MOV R3, [COLUNA]			; numero da coluna é a coordenada mais à esquerda
	MOV R5, R3						
	MOV R2, QUATRO
	ADD R5, R2					; numero da coluna que é a coordenada mais à direita
	MOV R4, LINHA				; numero da linha que é a coordenada mais a cima (28 em principio)
	MOV R6, R4
	MOV R2, TRES
	ADD R6, R2					; numero da linha que é a coordenada mais a baixo (ultima em principio)

	CALL embate					; devolve R11 , como o resultado de embate 
								;/ Há Embate - 1; Não há Embate - 0
	; todos os registos são irrelevantes a partir daqui
	MOV R3, UM
	CMP R3, R11					; compara para ver se houve embate
	JZ ha_embate_meteorito
	JMP colisao_meteorito_final

ha_embate_meteorito:
	MOV R10, 0
	MOV [TOCA_SOM], R10
	MOV R5, INFO_METEORITO
	MOV R1, [R5]								; linha do meteorito
	ADD R5, DOIS
	MOV R2, [R5]								; coluna do meteorito
	CALL estrutura_meteorito					; estrutura que que vai ser apagada
	CALL apaga_boneco							; apaga o meteorito que embateu

	MOV R1, LINHA				; linha do rover
	MOV R2, [COLUNA]
	MOV	R4, DEF_ROVER			; endereço da tabela que define o rover
	CALL	desenha_boneco		; desenha o rover a partir da tabela

	MOV R1, INFO_METEORITO	
	ADD R1, QUATRO
	MOV R2, [R1]					; R2 -> se o meteorito é bom ou mau
	CMP R3, R2
	JZ embate_rover_meteorito_bom
	JMP embate_rover_meteorito_mau

embate_rover_meteorito_bom:
	CALL gera_novo_meteorito					; gera outro meteorito 
	MOV R3, INFO_METEORITO
	MOV R1, [R3]								; linha do meteorito
	ADD R3, DOIS
	MOV R2, [R3]								; coluna do meteorito	
	CALL estrutura_meteorito					; estrutura do novo meteorito
	CALL desenha_boneco							; desenha o novo meteorito
	MOV R3, ENERGIA
	MOV R5, [R3]
	MOV R6, DEZ
	ADD R5, R6
	MOV [R3], R5
	JMP colisao_meteorito_final

embate_rover_meteorito_mau:						; acaba o jogo visto que o rover nao pode ser atingido por naves inimigas
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	JMP game_over


colisao_meteorito_final:						; serve apenas para os POPs
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	JMP colisao


embate_missil:
	PUSH R1 						; variavel de uso
	PUSH R2							; variavel de uso
	PUSH R3							; X top left 		do rover    
	PUSH R4							; Y top left 		do rover
	PUSH R5							; X bottom right 	do rover	
	PUSH R6							; Y bottom right 	do rover
	PUSH R7							; X top left 		do meteorito
	PUSH R8							; Y top left 		do meteorito
	PUSH R9							; X bottom right 	do meteorito
	PUSH R10						; Y bottom right 	do meteorito
	PUSH R11						; variavel de uso | embate depois da rotina

	MOV R1, [INFO_MISSIL]
	MOV R2, UM
	CMP R2, R1
	JNZ  colisao_missil_final

	; METEORITO ( primeiro porque precisamos de R4)

	MOV R11, INFO_METEORITO
	MOV R1, [R11]				; linha do meteorito
	ADD R11, DOIS
	MOV R2, [R11]				; coluna do meteorito
	CALL estrutura_meteorito	; devolve R4 com a estrutura do meteorito
	MOV R8, R1					; numero da linha que é a coordenada mais acima
	MOV R7, R2					; numero da coluna que é a coordenada mais à esquerda
	MOV R1, [R4]				; largura do meteorito
	ADD R4, DOIS
	MOV R2, [R4]				; altura do meteorito
	SUB R1, UM					; - 1 porque a coordenada ocupa espaço
	SUB R2, UM					; - 1 porque a coordenada ocupa espaço
	ADD R1, R8					; soma a linha com a altura
	ADD R2, R7					; soma a coluna com a largura 
	MOV R9, R2					; numero da coluna que é a coordenada mais à direita
	MOV R10, R1					; numero da linha que é a coordenada mais a baixo

	;Missil
	MOV R1, INFO_MISSIL
	MOV R2, DOIS
	ADD R1, R2
	MOV R4, [R1]				; numero da linha onde está o missil 	
	MOV R6, R4					; numero da linha onde está o missil
	ADD R1, R2
	MOV R3, [R1]				; numero da coluna onde está o missil 
	MOV R5, R3					; numero da coluna onde está o missil 	

	CALL embate					; devolve R11 , como o resultado de embate 
								;/ Há Embate - 1; Não há Embate - 0
	; todos os registos são irrelevantes a partir daqui
	MOV R1, UM
	CMP R1, R11					; compara para ver se houve embate
	JZ ha_embate_missil
	JMP colisao_missil_final

ha_embate_missil:					; açao depois de confirmado o embate
	MOV R10, 0
	MOV [TOCA_SOM], R10
	CALL destroi_missil
	CALL apaga_meteorito
	MOV R3, UM
	MOV R1, INFO_METEORITO	
	ADD R1, QUATRO
	MOV R2, [R1]					; R2 -> se o meteorito é bom ou mau
	CMP R3, R2
	JZ embate_missil_meteorito_bom
	JMP embate_missil_meteorito_mau

embate_missil_meteorito_bom:
	CALL gera_novo_meteorito
	MOV R3, INFO_METEORITO
	MOV R1, [R3]								; linha do meteorito
	ADD R3, DOIS
	MOV R2, [R3]								; coluna do meteorito	
	CALL estrutura_meteorito					; estrutura do novo meteorito
	CALL desenha_boneco							; desenha o novo meteorito
	JMP colisao_missil_final

embate_missil_meteorito_mau:
	CALL gera_novo_meteorito
	MOV R3, INFO_METEORITO
	MOV R1, [R3]								; linha do meteorito
	ADD R3, DOIS
	MOV R2, [R3]								; coluna do meteorito	
	CALL estrutura_meteorito					; estrutura do novo meteorito
	CALL desenha_boneco							; desenha o novo meteorito
	MOV R3, ENERGIA
	MOV R5, [R3]
	MOV R6, CINCO
	ADD R5, R6
	MOV [R3], R5
	JMP colisao_missil_final

colisao_missil_final:
	POP R11
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET 

embate: 	; rotina abstrata que verifica se houve embate entre meteorito e objeto (rover ou missil)
	;R3		; X top left 		do objeto    
	;R4		; Y top left 		do objeto
	;R5		; X bottom right 	do objeto	
	;R6		; Y bottom right 	do objeto
	;R7		; X top left 		do meteorito
	;R8		; Y top left 		do meteorito
	;R9		; X bottom right 	do meteorito
	;R10	; Y bottom right 	do meteorito

	CMP	R3, R9
	JGT	nao_ha_embate
	CMP	R7, R5
	JGT	nao_ha_embate
	CMP	R4, R10
	JGT	nao_ha_embate	
	CMP	R8, R6
	JGT	nao_ha_embate	
	JMP ha_embate


ha_embate:	
	MOV R11, 1
	RET
nao_ha_embate:	
	MOV R11, 0
	RET

apaga_meteorito:
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R5
	MOV R5, INFO_METEORITO
	MOV R1, [R5]								; linha do meteorito
	ADD R5, DOIS
	MOV R2, [R5]								; coluna do meteorito
	CALL estrutura_meteorito					; estrutura que que vai ser apagada
	CALL apaga_boneco							; apaga o meteorito que embateu
	POP R5
	POP R4
	POP R2
	POP R1
	RET

; **********************************************************************
; PROCESSO - Processo que gere as etapas do jogo
; 
;  Tambem contem outras rotinas referentes ao meteorito
; **********************************************************************
PROCESS SP_inicial_processo

processo:
	YIELD
	MOV	R1, [tecla_carregada]
	MOV R1, [TECLA]
	MOV R4, TECLA_D
	CMP R1, R4
	JZ final
	JMP processo

final:						; nao deixava voltar ao inicio no ciclo processo
	JMP inicio

reiniciar_variaveis:		; reinicia as variaveis para o jogo poder começar de novo
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R1, COLUNA
	MOV R3, 27
	MOV [R1], R3
	MOV R1, INFO_METEORITO
	MOV R3, -1
	MOV [R1], R3
	MOV R1, INFO_MISSIL
	MOV R3, ZERO
	MOV [R1], R3
	MOV R1, ENERGIA
	MOV R3, CEM
	MOV [R1], R3
	MOV R1, TECLA
	MOV R3, ZERO
	MOV [R1], R3
	POP R3
	POP R2
	POP R1
	RET

; **********************************************************************
; ENERGIA - Processo que verifica se a energia está acima de 0
; 
; **********************************************************************
PROCESS SP_inicial_energia
energia:
	YIELD
	MOV  R1, ENERGIA				; endereço do contador
	MOV R2, [R1]					; valor de energia
	MOV R3, ZERO
	CMP R2, R3
	JLE game_over
	JMP energia

; rotina terminal, caso aconteça o jogador perdeu o jogo e terá a opção de reinicia-lo
game_over:
	MOV R1, 2
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV [SELECIONA_CENARIO_FRONTAl], R1	; seleciona o cenário de fundo
	MOV	R1, [tecla_carregada]
	MOV R1, [TECLA]
	MOV R4, TECLA_E
	CMP R1, R4
	JZ final
	JMP game_over


