.data

.text
	main:
		addi $t0, $zero, 0

		while1: slti $t2, $t0, 10
			beq $t2, $zero, exit1
			addi $t0, $t0, 1
			j while1
		exit1:
		
		addi $t1, $zero, 9
		while2: slti $t2, $t1, 0 
			bne $t2, $zero, exit2 
			addi $t1, $t1, -1
			j while2
		exit2:
		
		addi $t0, $zero, 0
		while3: slti $t2, $t0, 10
			addi $t0, $t0, 1
			bne $t2, $zero, while3

	
	li $v0, 10
	syscall
