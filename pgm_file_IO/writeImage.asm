# Student ID = 260844811
####################################write Image#####################
.data
newline:	.asciiz "\n"
blank:		.asciiz " "
testOpen:	.asciiz "fail to open the file"
buffer:		.space 1024
array:		.space 1024
.text
.globl write_image
write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 -> P5, 1->P2)
	################# returns #################
	# void
	# Add code here.
	
	addi $sp,$sp,-4		# need to save $ra
	sw $ra,0($sp)		# because of nested subroutine calls here
	addi $sp,$sp,-4		# save s0
	sw $s0,0($sp)
	
	# save inputs
	move $s0,$a0	# s0 = address of struct
	move $s1,$a1	# s1 = ouput filename
	la $s2,buffer	# s2 = start of buffer
	move $s7,$a2	# s7 = type
	
	lw $s3,0($s0)	# t1 = width
	lw $t2,4($s0)	# t2 = height
	mul $s6,$s3,$t2	# s6 = array size
	
	# save info in struct into buffer that we want to write
	# store type info into buffer
	li $t0,'P'
	sb $t0,0($s2)	
	addi $s2,$s2,1	# next byte
	
	# determin type
	beq $a2,$0,P5	# s2 = 0 -> P5
			# else P2
P2:	li $t0,'2'
	sb $t0,0($s2)
	addi $s2,$s2,1	# next byte
	j next

P5:	li $t0,'5'
	sb $t0,0($s2)
	addi $s2,$s2,1	# next byte

next:	# save a whitespace
	li $t0,' '
	sb $t0,0($s2)
	addi $s2,$s2,1	# next byte
	
	# store width
	lw $a0,0($s0)	# load width in a0
	move $a1,$s2	# a1 = pointer
	jal itoa	
	add $s2,$s2,$v0	# update pointer
	
	# save a whitespace
	li $t0,' '
	sb $t0,0($s2)
	addi $s2,$s2,1	# next byte
	
	# store height
	lw $a0,4($s0)	# load height in a0
	move $a1,$s2	# a1 = pointer
	jal itoa
	add $s2,$s2,$v0	# update pointer
	
	# save a whitespace
	li $t0,' '
	sb $t0,0($s2)
	addi $s2,$s2,1	# next byte
	
	# store max
	lw $a0,8($s0)	# load max in a0
	move $a1,$s2	# a1 = pointer
	jal itoa
	add $s2,$s2,$v0	# update pointer
	
	# store newline
	la $t0,newline
	lb $t1,0($t0)
	sb $t1,0($s2)
	addi $s2,$s2,1	# update pointer
	
	# store content
	add $s0,$s0,12	# move struct to content
	li $s4,0	# set s4 as counter
	bne $s7,$0,P2store	# determine type
	
# P5
storeContent:
	lbu $t0,0($s0)	# load byte
	sb $t0,0($s2)	# store byte
	addi $s4,$s4,1	# counter++
	bge $s4,$s6,finContent	# meet last, s6 = width * height
	addi $s0,$s0,1	# next byte
	addi $s2,$s2,1	# update pointer
	j storeContent

# P2
P2store:
	lbu $a0,0($s0)	# load byte and pass as input
	move $a1,$s2	# pass pointer
	jal itoa
	addi $s4,$s4,1	# increment counter
	bge $s4,$s6,finContent	# meet last, s6 = width * height
	add $s2,$s2,$v0	# update pointer
	div $s4,$s3	# divide counter by width
	mfhi $t0	# t0 = s4 % width
	beq $t0,$0,nextLine
	# store a whitespace
	li $t0,' '
	sb $t0,0($s2)
	j q
	# store newline
nextLine:
	la $t0,newline
	lb $t1,0($t0)
	sb $t1,0($s2)
q:	addi $s0,$s0,1	# next byte
	addi $s2,$s2,1	# update pointer
	j P2store
	
	

finContent:	
	# open file for writing
	li $v0,13	# system call for open file
	move $a0,$s1	
	li $a1,1	# set flag to be 9, ie, write only for create and append
	li $a2,0	# ignore mode
	syscall

    	slt $t0,$v0,$0
	bne $t0,$0,fail
	j write
	
fail:	la $a0,testOpen		# set a0 to hold the address of what we want to print
	jal printstr
	j done
	
write:	
	move $s6,$v0	# save file discriptor
	# write following contents:
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
  	la   $a1,buffer   # address of buffer from which to write
  	li   $a2, 1024       # hardcoded buffer length
  	syscall  
  	j done
  	

# input: a0 = number, a1 = pointer
# ouput: v0 = pointer moved
itoa:	move $t0,$a0	# t0 = number input
	move $t1,$a1	# t1 = pointer
	add $v0,$0,$0	# v0 = 0
	li $t4,0
	li $t2,10
convLp:	blt $t0,$t2,save	# number < 10
	div $t0,$t2		# t0 = t0 / 10
	mflo $t0
	mfhi $t3		# t3 = t0 % 10
	addi $t3,$t3,48		# convert
	addi $sp,$sp,-1		# save in stack
	sb $t3,0($sp)
	addi $v0,$v0,1		# counter++
	j convLp
save:	addi $t0,$t0,48		# store MSB
	sb $t0,0($t1)
	addi $t1,$t1,1		# next position
storeLp:slt $t5,$t4,$v0
	beq $t5,$0,finConv
	lb $t0,0($sp)		# load from stack
	sb $t0,0($t1)
	addi $t1,$t1,1		# next position
	addi $sp,$sp,1		# free stack
	addi $t4,$t4,1		# counter++
	j storeLp
finConv:addi $v0,$v0,1
	jr $ra
	
	
	
printImage:	# print content of image to console
	# a0 has the address of the image
	move $t0,$a0	# save a0 in t0, now t0 has the address of the image
	
	lw $t1,0($t0)	# load width in t1
	move $a0,$t1	# print width
	jal printint
	
	la $a0,newline	# print newline
	jal printstr
	 
	lw $t2,4($t0)	# load height in t2
	move $a0,$t2	# print height
	jal printint
	
	la $a0,newline	# print newline
	jal printstr
	
	lw $t3,8($t0)	# load max in t3
	move $a0,$t3	# print max
	jal printint
	
	la $a0,newline	# print newline
	jal printstr
	
	addi $t0,$t0,12	# t0 points to the start of content
	mul $t4,$t1,$t2	# t4 hold size of content array
	li $t5,0	# set t5 as counter
	
print:	slt $t6,$t5,$t4
	beq $t6,$0,done
	
	lb $t1,0($t0)	# load byte
	move $a0,$t1	# print current byte
	jal printint
	la $a0,blank	# print blank
	jal printstr
	addi $t0,$t0,1	# next byte
	addi $t5,$t5,1	# increment counter
	j print

printint: li $v0, 1
	syscall
	jr $ra
	
printstr: li $v0, 4
	syscall
	jr $ra
			
done:	lw $s0,0($sp)		# restore s0
	addi $sp,$sp,4		# free stack
	lw $ra,0($sp)		# restore $ra
	addi $sp,$sp,4		# and release stack
	
	jr $ra
