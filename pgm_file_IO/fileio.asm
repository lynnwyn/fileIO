#Student ID = 260844811
############################ Q1: file-io########################
.data
			.align 2
inputTest1:		.asciiz "C:\\Users\\WYN\\Desktop\\hw\\COMP273\\A3\\template\\test1.txt"
			.align 2
inputTest2:		.asciiz "C:\\Users\\WYN\\Desktop\\hw\\COMP273\\A3\\template\\test2.txt"
			.align 2
outputFile:		.asciiz "C:\\Users\\WYN\\Desktop\\hw\\COMP273\\A3\\template\\copy.pgm"
			.align 2
buffer:			.space 1024
testOpen:		.asciiz "fail to open the file"
printText:		.asciiz "P2\n24 7\n15\n"

.text
.globl fileio

fileio:
	
	la $a0,inputTest1
	#la $a0,inputTest1
	jal read_file
	
	la $a0,outputFile
	jal write_file
	
	li $v0,10		# exit...
	syscall	
		

	
read_file:
	# $a0 -> input filename	
	
	# Opens file
	li $v0,13
	li $a1,0	# set flag to be 0, ie, read only
	li $a2,0	# ignore mode
	syscall
	move $s6,$v0	# save file discriptor
	
	# read file into buffer
	li $v0,14		# read from file
	move $a0,$s6		# set a0 to hold file discriptor
	la   $a1,buffer	# set a1 to hold the address of buffer which we want to read into	
	li   $a2,1024		# number of characters wanted to read
	syscall
	
	# print the content to the screen
	li $v0,4		# syscall for print string
	la $a0,buffer		# set a0 to hold the address of what we want to print
	syscall

	
	
	# close the file
	li $v0,16		# syscall for close file
	move $a0,$s6		# file discriptor to close
	syscall
	
	
	# return
	# Add code here
	
	jr $ra
	
write_file:
	# $a0 -> outputFilename
	
	# open file for writing
	li $v0,13	# system call for open file
	li $a1,1	# set flag to be 9, ie, write only for create and append
	li $a2,0	# ignore mode
	syscall

    	slt $t0,$v0,$0
	bne $t0,$0,fail
	j write
	
fail:	li $v0,4		# syscall for print string
	la $a0,testOpen		# set a0 to hold the address of what we want to print
	syscall
	j close
	
write:	move $s6,$v0	# save file discriptor
	
	# write following contents:
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
  	la   $a1, printText   # address of buffer from which to write
  	li   $a2, 11      # hardcoded buffer length
  	syscall  

	# P2
	# 24 7
	# 15
	# write out contents read into buffer

	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	la   $a1, buffer   # address of buffer from which to write
  	li   $a2, 1024       # hardcoded buffer length
  	syscall 
	
	# close file
close:	li $v0,16		# syscall for close file
	move $a0,$s6		# file discriptor to close
	syscall
	
	# Add  code here
	
	jr $ra
		  	  
