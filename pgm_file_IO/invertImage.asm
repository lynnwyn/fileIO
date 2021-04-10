#Student ID = 260844811
#################################invert Image######################
.data
.text
.globl invert_image
invert_image:
	# $a0 -> image struct
	#############return###############
	# $v0 -> new inverted image
	############################
	# Add Code
	addi $sp,$sp,-4		# need to save $s0
	sw $s0,0($sp)
	
	move $s0,$a0	# save input, s0 = image pointer
	lw $t0,8($s0)	# t0 = original max
	lw $t1,0($s0)	# t1 = width
	lw $t2,4($s0)	# t2 = height
	
	mul $s2,$t1,$t2	# s2 = size of content array
	
	addi $s1,$s0,12	# s1 = pointer to content array
	li $t7,0	# set t7 as counter
	# change content
change:	bge $t7,$s2,finChange
	lbu $t1,0($s1)	# load current byte
	sub $t1,$t0,$t1	# t1 = max - curr
	sb $t1,0($s1)	# store the byte back to array
	addi $t7,$t7,1	# counter++
	addi $s1,$s1,1	# next byte
	j change

finChange:
	# find new max
	li $t7,0	# set t7 as new max
	li $t6,0	# set t6 as counter
	addi $s1,$s0,12	# s1 = pointer to content array
	
find:	bge $t6,$s2,finMax
	lbu $t1,0($s1)	# load current byte
	bgt $t1,$t7,set
	addi $s1,$s1,1
	addi $t6,$t6,1
	j find

set:	move $t7,$t1
	addi $s1,$s1,1
	addi $t6,$t6,1
	j find

finMax:	# save new max back to struct
	addi $s1,$s0,8
	sw $t7,0($s1)
	j done

done:	move $v0,$s0
	lw $s0,0($sp)		# restore s0
	addi $sp,$sp,4		# free stack
	
	jr $ra
