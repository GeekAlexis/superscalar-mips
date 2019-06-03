.data
	myArray: .space 1
.text
	addi $t0, $zero, 1         
	addi $t1, $zero, 6
	start:
	addi $t2, $t2, 16
	addi $t0, $t0, 1
	beq $t0, $t1, exit
	j start
	exit:
	addi $t3, $zero, 4
	addi $t3, $t3, 3
	
	sw $t2, myArray($zero)
	addi $t2, $t2, 16
	
	lw $t9, myArray($zero)
	addi $t9, $t9, 16
	
	li $v0, 10
	syscall
