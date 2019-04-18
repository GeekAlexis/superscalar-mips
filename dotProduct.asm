.data

.text
	addi $t1, $zero, 28
	addi $t2, $zero, -240
	mult $t1, $t2
	mflo $t4
	
	addi $t1, $zero, 110
	addi $t2, $zero, 91
	mult $t1, $t2
	mflo $t3
	add $t4, $t4, $t3
	
	addi $t1, $zero, -41
	addi $t2, $zero, -101
	mult $t1, $t2
	mflo $t3
	add $t4, $t4, $t3
	
	addi $t1, $zero, 23
	addi $t2, $zero, 150
	mult $t1, $t2
	mflo $t3
	add $t4, $t4, $t3
	
	addi $t1, $zero, -67
	addi $t2, $zero, 88
	mult $t1, $t2
	mflo $t3
	add $t4, $t4, $t3 
	
	li $v0, 1
	add $a0, $zero, $t4
	
	syscall
	
