# Student ID = 260844811
##########################get pixel #######################
.data
errorMess:	.asciiz "pixel location out of image"
.text
.globl get_pixel
get_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	################return##################
	# $v0 -> value of image at (row,column)
	#######################################
	# Add Code
	addi $sp,$sp,-4		# need to save $s0
	sw $s0,0($sp)	
	
	move $s0,$a0	# save image struct pointer
	move $s1,$a1	# save row number
	move $s2,$a2	# save column number
	
	lw $t0,0($s0)	# t0 = width
	lw $t1,4($s0)	# t1 = height
	
	# error check
	bge $s1,$t1,error	# if row number > height then error
	bge $s2,$t0,error	# if col number > width then error
	
	# no error, find pixel
	addi $s0,$s0,12	# move pointer to start of content
#	addi $s1,$s1,-1	# calculate offset = (row)* width + col
	mul $t2,$s1,$t0
	add $t2,$t2,$s2
	add $s0,$s0,$t2	
#	addi $s0,$s0,-1	# move pointer
	
	lb $v0,0($s0)	# load output
	j done

error:	li $v0,4
	la $a0,errorMess
	syscall
	
	li $v0,0
	j done
	
	
done:	lw $s0,0($sp)		# restore $ra
	addi $sp,$sp,4		# and release stack

	jr $ra
