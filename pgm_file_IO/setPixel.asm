# Student ID = 260844811
##########################set pixel #######################
.data
outside:	.asciiz "pixel location out of image"

.text
.globl set_pixel
set_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	# $a3 -> new value (clipped at 255)
	###############return################
	#void
	# Add code here
	addi $sp,$sp,-4		# need to save $s0
	sw $s0,0($sp)
	
	move $s0,$a0	# save image struct pointer
	move $s1,$a1	# save row number
	move $s2,$a2	# save column number
	move $s3,$a3	# save new value
	
	# check if the location is within the image
	lw $t0,0($s0)	# t0 = width
	lw $t1,4($s0)	# t1 = height
	# error check
	bge $s1,$t1,error	# if row number > height then error
	bge $s2,$t0,error	# if col number > width then error
	
	# check if the input value is greater than 255
	li $t2,255
	bgt $s3,$t2,updateInput	# update input value if it's > 255
	
	# check max value
	lw $t3,8($s0)	# t3 = original max
	bgt $s3,$t3,updateMax	# update max if new value > original max
	
	# change pixel value
change:	lw $t0,0($s0)	# t0 = width
	lw $t1,4($s0)	# t1 = height
	addi $s0,$s0,12	# move pointer to start of content
#	addi $s1,$s1,-1	# calculate offset = (row-1)* width + col
	mul $t2,$s1,$t0
	add $t2,$t2,$s2
	add $s0,$s0,$t2	
#	addi $s0,$s0,-1	# move pointer
	
	sb $s3,0($s0)	# store new value
	j done

updateInput:
	li $s3,255	# update input value
	j change
	
updateMax:
	sw $s3,8($s0)	# update max
	j change
	
	
error:	li $v0,4
	la $a0,outside
	syscall
	j done

done:	lw $s0,0($sp)		# restore s0
	addi $sp,$sp,4		# free stack
		
	jr $ra
