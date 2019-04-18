.data
	myArray: .space 40
	newLine: .asciiz "\n"
	space: .asciiz " "


.text
	main:
		addi $s1, $zero, 78 # num = 78
		addi $v1, $zero, 0  # sum = 0
		addi $t3, $zero, 0 # creat an array
		
		addi $t0, $zero, 1
		addi $t1, $zero, 6
		while1: sltiu $t2, $t0, 6     # for(i = 1; i < 6; i++) { loop 5 times
			beq $t2, $zero, exit1 #   sum = sum + num
			add $v1, $v1, $s1     #   array[i - 1] = sum
			sw $v1, myArray($t3)  # }
			addi $t3, $t3, 4
			addi $t0, $t0, 1
			j while1
		exit1:
		
		addi $t1, $zero, 5 # product = num * 5
		mult $s1, $t1
		mflo $v1
		sw $v1, myArray($t3) # array[5] = product
				
		addi $t0, $zero, 1
		addi $t1, $zero, 4
		addu $t4, $zero, $t3          # j = 5
		addi $t3, $t3, -4             # 
		while2: slt $t2, $t1, $t0     # for(i = 4; i > 0; i--) { loop 4 times
			bne $t2, $zero, exit2 #   j++
			lw $t9, myArray($t3)  #   array[j] = array[i] - num
			addi $t3, $t3, -4     # }
			sub $v1, $t9, $s1
			addi $t4, $t4, 4
			sw $v1, myArray($t4)
			
			addi $t1, $t1, -1
			j while2
		exit2:
		
		addiu $t3, $t4, 4
		lui $s1, 0xffff
		ori $s1, $s1, 0xffff
		lui $s2, 0xffff
		ori $s2, $s2, 0xffff
		multu $s1, $s2 # multiply 0xFFFF_FFFF and 0xFFFF_FFFF
		mfhi $t6
		mflo $t5
		sw $t6, myArray($t3) # array[10] = reghi
		addiu $t3, $t3, 4
		sw $t5, myArray($t3) # array[11] = reglo
		
		addi $t3, $t3, 4
		andi $s2, $s1, 0xffff # array[12] = 0xFFFF_FFFF & 0x0000_FFFF
		sw $s2, myArray($t3)
		
		addi $s1, $zero, -1
		ori $s2, $zero, 0xff00
		subu $v1, $s1, $s2 # diff = 0xFFFF_FFFF - 0x0000_FF00 
		addi $t3, $t3, 4
		sw $v1, myArray($t3) # array[13] = diff
		
		addi $s1, $zero, 100
		addi $s2, $zero, -100
		sltu $t2, $s2, $s1 # x = (-100 < 100)
		addi $t3, $t3, 4
		sw $t2, myArray($t3) # array[14] = x
		sltu $t2, $s1, $s2 # x = (2'complement of -100 < 100)
		addi $t3, $t3, 4
		sw $t2, myArray($t3) # array[15] = x
		
		lui $s1, 0xff00
		ori  $s1, $s1, 0xff00 # x = 0xFF00_FF00
		ori $s2, $zero, 0xffff # y = 0x0000_FFFF 
		
		and $v1, $s1, $s2
		addi $t3, $t3, 4 # z = x & y
		sw $v1, myArray($t3) # array[16] = z
		
		or $v1, $s1, $s2 # z = x | y
		addi $t3, $t3, 4
		sw $v1, myArray($t3) # array[17] = z
		
		xor $v1, $s1, $s2 # z = x xor y
		addi $t3, $t3, 4
		sw $v1, myArray($t3) # array[18] = z
		
		xori $v1, $s1, 0xffff # z = x xor 0x0000_FFFF
		addi $t3, $t3, 4
		sw $v1, myArray($t3) # array[19] = z
		
		#xnor $v1, $s1, $s2 # z = x xnor y
		#addi $t3, $t3, 4
		#sw $v1, myArray($t3) # array[20] = z

	
	li $v0, 10
	syscall
