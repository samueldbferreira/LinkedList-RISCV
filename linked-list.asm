	.data
	.align 0
msg_entrada: .asciz "Insira um inteiro e uma string de at� 28 caracteres logo ap�s. -1 para encerrar.\n\n"
msg_saida: .asciz "\n\nOs dados de entrada foram os seguintes:\n\n"
separador: .asciz ", "
str_buffer: .asciz ""
	
	
	
	
	.text
	.align 2
	.globl main
main:
	# Registrador $s0 armazena n� de in�cio da lista. � iniciado em 0.
	mv s0, zero
	
	# Registrador $s1 armazena o n� final da lista. � iniciado em 0.
	mv s1, zero
		
	# Registrador $s2 armazena a quantidade de itens na lista. � iniciado em 0.
	mv s2, zero
	
	# Registrador $s3 armazena o inteiro -1.
	# �til para saber quando ocorre o fim da entrada de dados.
	# �til para identificar um n� como o �ltimo da lista.
	li s3, -1
	
	# Exibe mensagem solicitando a inser��o dos dados na lista.
	la a0, msg_entrada
	li a7, 4
	ecall

	
loop_entrada:
	# Leitura do inteiro e armazenamento deste em $t0.
	li a7, 5
	ecall
	mv t0, a0
	
	# Caso o inteiro digitado seja -1 a entrada de dados � encerrada.
	beq t0, s3, fim_entrada

	# Leitura de string e armazenamento desta em $t1.
	la a0, str_buffer
	li a1, 28
	li a7, 8
	ecall
	mv t1, a0
	
	# Defini��o em $t2 de "ponteiro" para pr�ximo item da lista em -1.
	# "Ponteiro" para pr�ximo item � inicializado em -1 pois a entrada atual pode ser a �ltima.
	li t2, -1

	# Aloca��o de 36 bytes para armazenar um novo n� da lista na heap.
	# 4 bytes para o inteiro, 28 bytes para a string e 4 bytes para apontar pr�ximo n�.
	li a0, 36
	li a7, 9
	ecall
	
	# Atualiza in�cio e/ou fim da lista.
	# Atualiza��o � feita considerando $s2, que possui o comprimento da lista.
	bgtz s2, n_insercao


primeira_insercao:
	# Caso em que lista ainda est� vazia ($s2 = 0).
	# $s0 e $s1 recebem endere�o do bloco de 36 bytes alocados.
	# Ou seja, in�cio e fim da lista passam a "apontar" para o endere�o de mem�ria alocada.
	mv s0, a0
	mv s1, a0
	

n_insercao:
	# Caso em que a lista j� possui pelo menos 1 item inserido ($s2 > 0).
	
	# Atualiza��o do "ponteiro" para pr�ximo item do n� que atualmente o �ltimo da lista.
	# �ltimos 4 bytes do n� final agora armazenam o endere�o da mem�ria alocada acima.
	# Algo como: fim->prox = novoItem.
	sw a0, 32(s1)
	
	# Registrador $s1 que armazena o �ltimo n� � atualizado.
	# $s1 recebe o endere�o da mem�ria alocada para o novo item.
	# Algo como: fim = novoItem.
	mv s1, a0

	# Escreve o inteiro ($t0) na heap.
	sw t0, 0(s1)

	# A escrita da string ($t1) ocorre byte a byte na heap.
	# Escrita byte a byte exige itera��o sobre a string e $s1 (fim da lista).
	# Para n�o perder o fim da lista, $t5 recebe o conte�do de $s1.
	# $t5 � incrementado em 4 bytes para "pular" o inteiro e n�o sobrescrev�-lo.
	mv t5, s1
	addi t5, t5, 4
	
	
escrita_str:
	# Byte da string � carregado em $t6.	
	lb t6, 0(t1)
	
	# Se o byte carregado � nulo, ent�o n�o h� mais o que ser escrito.
	# String acabou e branch para "fim_escrita_str";
	beqz t6, fim_escrita_str
	
	# Escreve o byte carregado da string no local indicado por $t5. 
	sb t6, 0(t5)
	
	# Incrementa $t1 e $t5. Pr�ximo caractere e pr�ximo local para armazenamento.
	addi t1, t1, 1
	addi t5, t5, 1
	
	j escrita_str

	
fim_escrita_str:
	# Escreve ponteiro do n� para pr�ximo item.
	# No caso, � o -1 que est� sendo escrito.
	sw t2, 32(s1)
	
	# Incrementa o tamanho da lista.
	addi s2, s2, 1
	
	# Nova itera��o do loop de entrada. Permite uma nova entrada de dados.
	j loop_entrada
	

fim_entrada:
	# Como usu�rio inseriu -1, mensagem anunciando a exibi��o dos dados inseridos � exibida.
	la a0, msg_saida
	li a7, 4
	ecall
	
	# Caso n�o tenham sido adicionados itens na lista o programa encerra sem exibi��es.
	beqz s2, fim_saida
	
	
loop_saida:
	# In�cio da exibi��o dos dados.
	# Itera��o sobre a lista � feita atualizando o registrador que armazena o �nicio da lista ($s0).

	# Se $s0 � igual a $s3, que armazena -1, ent�o n�o h� mais o que ser exibido. Fim da sa�da.
	beq s0, s3, fim_saida
	
	# Inteiro � carregado da heap, armazenado em $a0 e impresso.
	lw a0, 0(s0)
	li a7, 1
	ecall
	
	# Separador (", ") � carregado a partir da label, armazenado em $a0 e impresso.
	la a0, separador
	li a7, 4
	ecall
							
	# String � carregada da heap e impressa, byte a byte.
	# Carga e impress�o byte a byte exige itera��o sobre a string e $s0 (in�cio da lista).
	# Para n�o perder o in�cio da lista, $t2 recebe o conte�do de $s0.
	# $t2 � incrementado em 4 bytes para ignorar o inteiro e n�o imprimi-lo.				
	mv t2, s0
	addi t2, t2, 4


print_str:
	# Byte da string � carregado em $t3.		
	lb t3, 0(t2)
	
	# Se o byte carregado � nulo, ent�o n�o h� mais o que ser impresso.
	# String acabou e branch para "fim_leitura_str";
	beqz t3, fim_print_str
	
	# Byte (caractere) carregado � impresso.
	mv a0, t3
	li a7, 11
	ecall
	
	# Incrementa $t2. Pr�ximo caractere para impress�o.
	addi t2, t2, 1
	
	# Nova itera��o do loop. Permite uma impress�o de caractere.
	j print_str


fim_print_str:
	# Carrega o endere�o do pr�ximo item da lista.
	lw t5, 32(s0)
	
	# Passa para $s0 o que foi carregado anteriormente e atualiza o in�cio.
	# Algo como: inicio = inicio->prox.
	mv s0, t5
	
	# Nova itera��o do loop de sa�da. Permite impress�o dos dados de um pr�ximo n�.
	j loop_saida


fim_saida:
	# Encerra o programa
	mv a0, zero
	li a7, 93
	ecall

