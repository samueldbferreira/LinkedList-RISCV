	.data
	.align 0
msg_entrada: .asciz "Insira um inteiro e uma string de até 28 caracteres logo após. -1 para encerrar.\n\n"
msg_saida: .asciz "\n\nOs dados de entrada foram os seguintes:\n\n"
separador: .asciz ", "
str_buffer: .asciz ""
	
	
	
	
	.text
	.align 2
	.globl main
main:
	# Registrador $s0 armazena nó de início da lista. É iniciado em 0.
	mv s0, zero
	
	# Registrador $s1 armazena o nó final da lista. É iniciado em 0.
	mv s1, zero
		
	# Registrador $s2 armazena a quantidade de itens na lista. É iniciado em 0.
	mv s2, zero
	
	# Registrador $s3 armazena o inteiro -1.
	# Útil para saber quando ocorre o fim da entrada de dados.
	# Útil para identificar um nó como o último da lista.
	li s3, -1
	
	# Exibe mensagem solicitando a inserção dos dados na lista.
	la a0, msg_entrada
	li a7, 4
	ecall

	
loop_entrada:
	# Leitura do inteiro e armazenamento deste em $t0.
	li a7, 5
	ecall
	mv t0, a0
	
	# Caso o inteiro digitado seja -1 a entrada de dados é encerrada.
	beq t0, s3, fim_entrada

	# Leitura de string e armazenamento desta em $t1.
	la a0, str_buffer
	li a1, 28
	li a7, 8
	ecall
	mv t1, a0
	
	# Definição em $t2 de "ponteiro" para próximo item da lista em -1.
	# "Ponteiro" para próximo item é inicializado em -1 pois a entrada atual pode ser a última.
	li t2, -1

	# Alocação de 36 bytes para armazenar um novo nó da lista na heap.
	# 4 bytes para o inteiro, 28 bytes para a string e 4 bytes para apontar próximo nó.
	li a0, 36
	li a7, 9
	ecall
	
	# Atualiza início e/ou fim da lista.
	# Atualização é feita considerando $s2, que possui o comprimento da lista.
	bgtz s2, n_insercao


primeira_insercao:
	# Caso em que lista ainda está vazia ($s2 = 0).
	# $s0 e $s1 recebem endereço do bloco de 36 bytes alocados.
	# Ou seja, início e fim da lista passam a "apontar" para o endereço de memória alocada.
	mv s0, a0
	mv s1, a0
	

n_insercao:
	# Caso em que a lista já possui pelo menos 1 item inserido ($s2 > 0).
	
	# Atualização do "ponteiro" para próximo item do nó que atualmente o último da lista.
	# Últimos 4 bytes do nó final agora armazenam o endereço da memória alocada acima.
	# Algo como: fim->prox = novoItem.
	sw a0, 32(s1)
	
	# Registrador $s1 que armazena o último nó é atualizado.
	# $s1 recebe o endereço da memória alocada para o novo item.
	# Algo como: fim = novoItem.
	mv s1, a0

	# Escreve o inteiro ($t0) na heap.
	sw t0, 0(s1)

	# A escrita da string ($t1) ocorre byte a byte na heap.
	# Escrita byte a byte exige iteração sobre a string e $s1 (fim da lista).
	# Para não perder o fim da lista, $t5 recebe o conteúdo de $s1.
	# $t5 é incrementado em 4 bytes para "pular" o inteiro e não sobrescrevê-lo.
	mv t5, s1
	addi t5, t5, 4
	
	
escrita_str:
	# Byte da string é carregado em $t6.	
	lb t6, 0(t1)
	
	# Se o byte carregado é nulo, então não há mais o que ser escrito.
	# String acabou e branch para "fim_escrita_str";
	beqz t6, fim_escrita_str
	
	# Escreve o byte carregado da string no local indicado por $t5. 
	sb t6, 0(t5)
	
	# Incrementa $t1 e $t5. Próximo caractere e próximo local para armazenamento.
	addi t1, t1, 1
	addi t5, t5, 1
	
	j escrita_str

	
fim_escrita_str:
	# Escreve ponteiro do nó para próximo item.
	# No caso, é o -1 que está sendo escrito.
	sw t2, 32(s1)
	
	# Incrementa o tamanho da lista.
	addi s2, s2, 1
	
	# Nova iteração do loop de entrada. Permite uma nova entrada de dados.
	j loop_entrada
	

fim_entrada:
	# Como usuário inseriu -1, mensagem anunciando a exibição dos dados inseridos é exibida.
	la a0, msg_saida
	li a7, 4
	ecall
	
	# Caso não tenham sido adicionados itens na lista o programa encerra sem exibições.
	beqz s2, fim_saida
	
	
loop_saida:
	# Início da exibição dos dados.
	# Iteração sobre a lista é feita atualizando o registrador que armazena o ínicio da lista ($s0).

	# Se $s0 é igual a $s3, que armazena -1, então não há mais o que ser exibido. Fim da saída.
	beq s0, s3, fim_saida
	
	# Inteiro é carregado da heap, armazenado em $a0 e impresso.
	lw a0, 0(s0)
	li a7, 1
	ecall
	
	# Separador (", ") é carregado a partir da label, armazenado em $a0 e impresso.
	la a0, separador
	li a7, 4
	ecall
							
	# String é carregada da heap e impressa, byte a byte.
	# Carga e impressão byte a byte exige iteração sobre a string e $s0 (início da lista).
	# Para não perder o início da lista, $t2 recebe o conteúdo de $s0.
	# $t2 é incrementado em 4 bytes para ignorar o inteiro e não imprimi-lo.				
	mv t2, s0
	addi t2, t2, 4


print_str:
	# Byte da string é carregado em $t3.		
	lb t3, 0(t2)
	
	# Se o byte carregado é nulo, então não há mais o que ser impresso.
	# String acabou e branch para "fim_leitura_str";
	beqz t3, fim_print_str
	
	# Byte (caractere) carregado é impresso.
	mv a0, t3
	li a7, 11
	ecall
	
	# Incrementa $t2. Próximo caractere para impressão.
	addi t2, t2, 1
	
	# Nova iteração do loop. Permite uma impressão de caractere.
	j print_str


fim_print_str:
	# Carrega o endereço do próximo item da lista.
	lw t5, 32(s0)
	
	# Passa para $s0 o que foi carregado anteriormente e atualiza o início.
	# Algo como: inicio = inicio->prox.
	mv s0, t5
	
	# Nova iteração do loop de saída. Permite impressão dos dados de um próximo nó.
	j loop_saida


fim_saida:
	# Encerra o programa
	mv a0, zero
	li a7, 93
	ecall

