# Student ID = 1234567
###############################rescale image######################
.data
.text
.globl rescale_image
rescale_image:
	# $a0 -> image struct
	############return###########
	# $v0 -> rescaled image
	######################
	# Add Code
	
	addi $sp,$sp,-4		# need to save $s0
	sw $s0,0($sp)
	
	move $s0,$a0	# save input, s0 = image pointer
	lw $s1,8($s0)	# s1 = original max
	lw $t1,0($s0)	# t1 = width
	lw $t2,4($s0)	# t2 = height
	
	mul $s2,$t1,$t2	# s2 = size of content array
	
	# find original min
	addi $s3,$s0,12	# s3 = pointer to content array
	move $t7,$s1	# set t7 as temp min
	
	li $t6,0	# set t6 as counter
find:	bge $t6,$s2,finMin	# if counter >= array size
	lbu $t1,0($s3)	# load current byte
	blt $t1,$t7,set
	addi $s3,$s3,1
	addi $t6,$t6,1
	j find
	
set:	move $t7,$t1
	addi $s3,$s3,1
	addi $t6,$t6,1
	j find

finMin:	# now t7 has original min
	# check if max - min = 0
	sub $t1,$s1,$t7	# t1 = max - min
	beq $t1,$0,done

	addi $s3,$s0,12	# s3 = pointer to content array
	li $t6,0	# set t6 as counter
	addiu $s7,$0,255
	mtc1 $s7,$f6
	cvt.s.w $f6,$f6		# f6 = 255
	
	mtc1 $s1,$f7
	cvt.s.w $f7,$f7		# f7 = max
	mtc1 $t7,$f8
	cvt.s.w $f8,$f8		# f8 = min
	
	sub.s $f1,$f7,$f8	# f1 = max - min
	
rescale:	
	bge $t6,$s2,finRescale	# if counter >= array size
	lbu $t1,0($s3)	# load current byte
	
	mtc1 $t1,$f2
	cvt.s.w $f2,$f2	# f2 = current value
	
	sub.s $f2,$f2,$f8	# f2 = current value - min
	
	mul.s $f2,$f2,$f6	# f2 = (current value - min) * 255
	
	div.s $f0,$f2,$f1	# f0 = [(current value - min) * 255] / (max - min)
	round.w.s $f0,$f0	# round the result
	mfc1 $t1,$f0
	sb $t1,0($s3)	# store back to array
	addi $s3,$s3,1	# next byte
	addi $t6,$t6,1	# counter++
	j rescale


finRescale:
	# update new max
	li $t7,0	# set t7 as new max
	li $t6,0	# set t6 as counter
	addi $s1,$s0,12	# s1 = pointer to content array
	
update:	bge $t6,$s2,finish
	lbu $t1,0($s1)	# load current byte
	bgt $t1,$t7,setM
	addi $s1,$s1,1
	addi $t6,$t6,1
	j update

setM:	move $t7,$t1
	addi $s1,$s1,1
	addi $t6,$t6,1
	j update

finish:	# save new max back to struct
	addi $s1,$s0,8
	sw $t7,0($s1)
	j done
	
done:	
	move $v0,$s0
	lw $s0,0($sp)		# restore s0
	addi $sp,$sp,4		# free stack
	
	jr $ra
