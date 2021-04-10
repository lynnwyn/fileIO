#Student ID = 260844811
#########################Read Image#########################
.data
buffer:			.space 1024
header:			.space 1024

P2:	.asciiz "P2"
P5:	.asciiz "P5"

newline:	.asciiz "\n"
blank:	.asciiz " "
cr:	.asciiz "\r"
tab:	.asciiz "	"


.text
		.globl read_image
read_image:
	# $a0 -> input file name
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	# Add code here
	
	addi $sp,$sp,-40	# need to save $ra
	sw $ra,0($sp)		# because of nested subroutine calls here
	
	# open input file
	li $v0,13
	li $a1,0	# set flag to be 0, ie, read only
	li $a2,0	# ignore mode
	syscall
	move $s6,$v0	# save file discriptor
	
	# read header, specify how many digits the header has
	li $v0,14		# read from file
	move $a0,$s6		# set a0 to hold file discriptor
	la   $a1,buffer	# set a1 to hold the address of buffer which we want to read into	
	li   $a2,1024		# number of characters wanted to read
	syscall
	
	la $s0,buffer	# s0 holds the address of the buffer
	addi $s0,$s0,3	# skip type and first whitespce, t0 holds the MSB of width
	li $s7,1	# set s7 to be the whitespace counter
	li $s5,0	# set s5 to be the switch that determines if the character is a whitespace or not
			# if yes, s5 = 1, else s5 = 0
			
		li $t7,3	# set t7 as digit counter
				# first determine how many digits the number has
findLength:	lb $s1,0($s0)	# s1 gets current digit from header
		move $a0,$s1
		jal whitespace
		li $t0,4
		addi $t7,$t7,1
		beq $s7,$t0,cont	# if there is 4 whitespaces then found the length of header
		addi $s0,$s0,1	# next digit
		j findLength
		
cont:

## t7 now has the header length, including last whitespace
	# find width	
	la $s0,buffer	# s0 holds the address of the buffer
	addi $s0,$s0,3	# skip type and first whitespce, s0 holds the MSB of width
	
	# check how many digits width has
	li $s5,0	# set s5 to be the switch that determines if the character is a whitespace or not
			# if yes, s5 = 1, else s5 = 0
	li $t0,0	# set t0 as digit counter
				# first determine how many digits the number has
			
Wdgtcounter:	lb $s1,0($s0)	# s1 gets current digit from header
		move $a0,$s1
		jal whitespace
	
		bne $s5,$0,finWCount	# the character read in is whitespace (switch s5 is 1)
					# ie, finish counting digits
		addi $t0,$t0,1	# increment counter
		addi $s0,$s0,1	# next digit
		j Wdgtcounter
	
finWCount:
		# now s0 is at the whitespace after width
		addi $s0,$s0,-1		# make s0 hold LSB of width
		# t0 holds the number of digits width has
		# want to convert width in the header into an int
		
		la $s1,buffer	# s1 holds the address of the buffer
		addi $s1,$s1,2	# s1 sits 1 position before the MSB of width
		
		# s2 is sumtotal
		li $s2,0
		
		li $t1, 10      #set t0 to be 10, used for decimal conversion
		li $t2, 1
		
		# load LSB of width
		lb $t3,0($s0)
		addi $t3,$t3,-48	# convert to decimal
		add $s2,$s2,$t3		# add LSB decimal value to s2
		
		addi $s0,$s0,-1		# decrement width size

loopW:	# loop for all digits preceeding LSB
	mul $t2,$t2,$t1		# multiply power by 10
	beq $s1,$s0,foundWidth	# exit if all the digits have been summed
	lb $t3,0($s0)		# load byte
	addi $t3,$t3,-48	# convert
	mul $t3,$t3,$t2		# t3*10^(counter)
	add $s2,$s2,$t3		# sum
	addi $s0,$s0,-1		# previous byte
	j loopW

foundWidth:	# now s2 holds the width in decimal

	# find height
	# now s0 is at 1 position before width, t0 holds the length of width
	addi $t0,$t0,2
	add $s0,$s0,$t0		# s0 is now at the MSB of height
	move $s3,$s0		# save the address of MSB of height
	
	# check how many digits height has
	li $s5,0	# set s5 to be the switch that determines if the character is a whitespace or not
			# if yes, s5 = 1, else s5 = 0
	li $t0,0	# set t0 as digit counter
				# first determine how many digits the number has
			
Hdgtcounter:	lb $s1,0($s0)	# s1 gets current digit from header
		move $a0,$s1
		jal whitespace
	
		bne $s5,$0,finHCount	# the character read in is whitespace (switch s5 is 1)
					# ie, finish counting digits
		addi $t0,$t0,1	# increment counter
		addi $s0,$s0,1	# next digit
		j Hdgtcounter
	
finHCount:
		# now s0 is at the whitespace after height
		addi $s0,$s0,-1		# make s0 hold LSB of height
		# s3 holds the number of digits height has
		# want to convert height in the header into an int
		
		move $s1,$s3	# s1 holds the address of MSB
		addi $s1,$s1,-1	# s1 sits 1 position before the MSB of width
		
		# s3 is sumtotal
		li $s3,0
		
		li $t1, 10      #set t0 to be 10, used for decimal conversion
		li $t2, 1
		
		# load LSB of height
		lb $t3,0($s0)
		addi $t3,$t3,-48	# convert to decimal
		add $s3,$s3,$t3		# add LSB decimal value to s3
		
		addi $s0,$s0,-1		# decrement height size

loopH:	# loop for all digits preceeding LSB
	mul $t2,$t2,$t1		# multiply power by 10
	beq $s1,$s0,foundHeight	# exit if all the digits have been summed
	lb $t3,0($s0)		
	addi $t3,$t3,-48
	mul $t3,$t3,$t2		# t3*10^(counter)
	add $s3,$s3,$t3
	addi $s0,$s0,-1
	j loopH

foundHeight:	# now s3 holds the height in decimal

	# find max
	# now s0 is at 1 position before height, t0 holds the length of height
	addi $t0,$t0,2		# skip 2 whitespaces
	add $s0,$s0,$t0		# s0 is now at the MSB of max
	move $s4,$s0		# save the address of MSB of max
	
	# check how many digits max has
	li $s5,0	# set s5 to be the switch that determines if the character is a whitespace or not
			# if yes, s5 = 1, else s5 = 0
	li $t0,0	# set t0 as digit counter
				# first determine how many digits the number has
			
Mdgtcounter:	lb $s1,0($s0)	# s1 gets current digit from header
		move $a0,$s1
		jal whitespace
	
		bne $s5,$0,finMCount	# the character read in is whitespace (switch s5 is 1)
					# ie, finish counting digits
		addi $t0,$t0,1	# increment counter
		addi $s0,$s0,1	# next digit
		j Mdgtcounter
	
finMCount:
		# now s0 is at the whitespace after height
		addi $s0,$s0,-1		# make s0 hold LSB of height
		# t0 holds the number of digits height has
		# want to convert height in the header into an int
		
		move $s1,$s4	# s1 holds the address of MSB
		addi $s1,$s1,-1	# s1 sits 1 position before the MSB of width
		
		# s4 is sumtotal
		li $s4,0
		
		li $t1, 10      #set t0 to be 10, used for decimal conversion
		li $t2, 1
		
		# load LSB of height
		lb $t3,0($s0)
		addi $t3,$t3,-48	# convert to decimal
		add $s4,$s4,$t3		# add LSB decimal value to s3
		
		addi $s0,$s0,-1		# decrement height size

loopM:	# loop for all digits preceeding LSB
	mul $t2,$t2,$t1		# multiply power by 10
	beq $s1,$s0,foundMax	# exit if all the digits have been summed
	lb $t3,0($s0)		
	addi $t3,$t3,-48
	mul $t3,$t3,$t2		# t3*10^(counter)
	add $s4,$s4,$t3
	addi $s0,$s0,-1
	j loopM
	
foundMax:	# now s4 holds the max in decimal
		# in conclusion, s2 = width, s3 = height, s4 = max
		# t7 is the length of header
		# want array size
		
	# specify tpye of the pgm file read in
	# t7 holds the length of header 

		la $t0,buffer
		addi $t0,$t0,1
		
		la $t1,P2
		addi $t1,$t1,1
	
cmp:	lb $t2,0($t0)	# get second bit from what has been read in
	lb $t3,0($t1)	# get second bit from P2
	bne $t2,$t3,cmpne	# different, means type is P5
	beq $t2,$t3,cmpeq	# same, means type is P2
	
cmpne:		# P5 (t7 holds the length of header)
		mul $t0,$s2,$s3		# t0 holds width * height
		
		# create a struct of the size t0+12
		addi $t0,$t0,12
		move  $a0, $t0         # t0 number of bytes to request 
		li  $v0, 9          # syscall for performing the request
		syscall 
		
		sw $s2,($v0)	# int width = s2
		sw $s3,4($v0)	# int height = s3
		sw $s4,8($v0)	# int max = s4
		
		la $s0,buffer
		add $s0,$s0,$t7	# s0 sits on the first digit of content
		
		move $s1,$v0	# save v0 in s1
		addi $v0,$v0,12	# move v0 to right position
		
		mul $t0,$s2,$s3		# t0 holds width * height
		li $t3,0		# set t3 as counter
		
lp:	# loop to store the array in struct
	# t1 is pointer to the array, t0 is array size
	slt $t4,$t3,$t0	# t3(stored number),t0(total number)
	beq $t4,$0,done	# t3 !< t0 <=> t3 = t0
	lb $t2,0($s0)	# load element of content
	sb $t2,0($v0)	# store in space
	addi $t3,$t3,1	# counter++
	addi $v0,$v0,1	# next byte in space
	addi $s0,$s0,1	# next element
	j lp
	


	# P2 (t7 holds the length of header)	
cmpeq:		mul $t0,$s2,$s3		# t0 holds width * height
		
		# create a struct of the size t0+12
		addi $t0,$t0,12
		move  $a0, $t0         # t0 number of bytes to request 
		li  $v0, 9          # syscall for performing the request
		syscall 
		
		sw $s2,($v0)	# int width = s2
		sw $s3,4($v0)	# int height = s3
		sw $s4,8($v0)	# int max = s4
		
		la $s0,buffer
		add $s0,$s0,$t7	# s0 sits on the first digit of content
		
		move $s1,$v0	# save v0 in s1
		addi $v0,$v0,12	# move v0 to right position
		
		mul $t0,$s2,$s3		# t0 holds width * height
		li $s3,0		# set s3 as counter
		
		
		
P2loop:		slt $t4,$s3,$t0
		beq $t4,$0,done
		li $s2,0		# s2 is digit counter (see how many digit current element has)
		
ctdigits:	lb $t1,0($s0)	# read a byte
		move $a0,$t1
		jal whitespace
		bne $s5,$0,doneCount	# switch s5 = 1, whitespace found
		addi $s2,$s2,1	# increment digit counter
		addi $s0,$s0,1	# next byte
		j ctdigits

doneCount:	# s2 now has the number of digits of an element of the content array
		# need to convert it from string to int
		# s0 is at the whitespace after the element
		
		addi $s3,$s3,1	# increment counter of bytes, since one decimal value has been found
		
		sub $t1,$s0,$s2		# s0 - s2 = address of MSB of the current element
					# store it in t1
		addi $t1,$t1,-1		# t1 is one positon before MSB
		addi $t2,$s0,-1		# t2 is at the LSB
		
		addi $s0,$s0,1		# s0 is now at the MSB of next element
		
		li $s7,0		# s7 = sum total
		
		li $t7,10
		li $t6,1
		
		lb $t5,0($t2)		# load LSB
		addi $t5,$t5,-48	# convert to decimal
		add $s7,$s7,$t5		# sum up
		addi $t2,$t2,-1		# one byte before
		
sum:	mul $t6,$t6,$t7		# multiply power by 10
	beq $t2,$t1,save	# exit loop if all digits are met
	lb $t5,0($t2)		# load digit
	addi $t5,$t5,-48	# convert to decimal
	mul $t5,$t5,$t6		# mult by power
	add $s7,$s7,$t5		# sum up
	addi $t2,$t2,-1		# previous digit
	j sum
	
save:	# now s7 has the value of the element in decimal
	# want to save it into struct
	sb $s7,0($v0)
	addi $v0,$v0,1
	j P2loop


	# check whitespace
whitespace:	
		sw $t1,4($sp)
		sw $t2,8($sp)
		sw $t3,12($sp)
		sw $t4,16($sp)
		sw $t6,20($sp)
		
		la $t6,newline
		lb $t4,0($t6)
		beq $t4,$a0,met
		
		la $t1,blank
		lb $t4,0($t1)
		beq $t4,$a0,met
		
		la $t2,cr
		lb $t4,0($t2)
		beq $t4,$a0,met
		
		la $t3,tab
		lb $t4,0($t3)
		beq $t4,$a0,met
		
		add $s5,$0,$0	# set the switch to be 0
back:		lw $t1,4($sp)
		lw $t2,8($sp)
		lw $t3,12($sp)
		lw $t4,16($sp)
		lw $t6,20($sp)
		jr $ra
	# meet a whitespace
met:	addi $s7,$s7,1	# increment the whitespace counter
	li $s5,1	# set the switch to be 1
	j back
	
done:	
	lw $ra,0($sp)		# restore $ra
	addi $sp,$sp,40		# and release stack
	
	move $v0,$s1
	
	jr $ra
