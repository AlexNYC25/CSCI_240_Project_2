# Project 2 final by Alexis Montes
# Basic algorithm
# fib(n) 
#	if (n == 1 || n == 2) return 1
#	else (return fib(n-1) + fib(n-2)


# FIb reference
# fib(1) =1
# fib(2) =1
# fib(3) =2
# fib(4) =3
# fib(5) =5
#
# Fibanocci numbers
# Note any value above 46 will generate an overflow.
# https://oeis.org/A000045/b000045.txt gives me a list of first 2000 Fibanocci numbers
.data
n:		.word		1
ask:		.asciiz  	"Input a positive integer value \n"
result:		.asciiz 	"The result is "
finishedMES:	.asciiz 	"\n The fibonaci program has finished."
.text

main:
# print the ask string
	li	$v0, 4
	la	$a0, ask
	syscall 

# get the input value
	li	$v0, 5
	syscall

# save input value
	add 	$t0,$zero, $v0
	sw		$t0, n

# sets up preliminary values
	add	$t2, $zero, 1	# uses t2 for previous
	add	$t3, $zero, 1	# uses t3 for current

# loads up value stored in n and then saces it in s0, then moving the value
# and then saves it in the argument a0 then runs fib
	la 	$s0,n
	lw 	$a0, 0($s0)
	jal fib

# move what ever is returned into $a0, then uses a system call to print the
# value that was returnd
	move 	$a0, $v0
	li 	$v0,1
	syscall
	b finished



fib:
	beq 	$a0, 1, return_1 	# if n = 1 return 1
	beq 	$a0, 2, return2		# if n = 1 return 1


# set up a if loop to check current value, if greater than 1, branch to else
# move the result into the return register, and then return
	bgt 	$a0, 1,else
	move 	$v0, $a0
	jr $ra

# if the value is greater then 1
	li 	$t0,1   		# Check for  number 1 start my returns, special case
	beq 	$a0, $t0,  return_1 	# Not at end, call fib again.

# Check for value of 2

	li 	$t0,2   		# Check for 2 special case
	blt 	$a0, $t0,  return2 	# Not at end, call fib again.

#Done with cases for 1 and 2, lets do it for all other numbers.

else:
# Done with special cases, this is from GE 3
# $s0	|0($s0)	|4($s0)	|8($s0)	|
# ----------------------------------
# 	| $ra	| $a0	| $v0	|
#	|return	|curent	|new	|
#	|addres	|value	|value	|
#----------------------------------- 
#
# Over all same code as return2 but with a larger stack to do math, since fib(2) can be run quickly with just one int
		
	# addi	$a0, $a0, -1

# first we need to save 3 different values in the stack so we subtract 12
# from the stack pointer
	sub 	$sp, $sp, 12

# then we save the adress of $ra in the first int, then we save the adress
# of a0 in the second int
	sw   	$ra, 0($sp) 		# we need to store the return adress so the recursive function knows where to return when sub finsihed
					# or else we get an error
	sw   	$a0,4($sp)



############################# fib (n-1)
# now we subtract 1 from a0, then run fib using the new value of a0
       addi 	$a0, $a0, -1	# decrement the counter
       jal fib
       
       
       sw	$v0, 8($sp)

# load the value that is in the value of the second int or the value in a0
       lw   	$a0, 4($sp)


######################## fib (n-2)
# subtract 2 from a0 and then run fib using the new value of a0, saves in v0 for the moment
       addi 	$a0, $a0, -2	# decrement the counter by 2
       jal fib
 
 
# calculations
# loads the result from the third int, which represents the return value
# we use the second return register so;

       lw  	$t4, 8($sp)

######################## return fib(n-1) + fib (n-2)
# adds the previous value with the current value and saves it as
# the current value
       add 	$v0, $v0, $t4

# restores the return adress, then the stack, then returns
       lw  	$ra, 0($sp)
       addi 	$sp,$sp,12
       jr 	$ra				# gets the return location from the stack and returns to upper level
       						# returning the value of fib(n) that has been calculated using the stack


# Rest of the code to account for numbers GE 3

return_1:
		#addi $v0, $0, 1 # yes : return 1
		addi $v0,$zero,1 # vo will be 1 (Special case)
		jr $ra # return to Main
		add	$a0, $a0, -1
		
# The return2 part only needed one register because program only looped once to get value 1
# so for the longer else loop we need more space in the stack
return2:
		addi $a1,$zero,1 #previous number is is 1 for special case
		addi $v0,$zero,1 #current number is is 1 for special case

		addi $a0,$a0 -1 # Decrement the counter

		add $sp, $sp, -4 #make room for 1 registers on the stack.
		sw $ra,0($sp)     # store $ra on the stack
		jal fib

		lw $ra , 0($sp ) # restore restore restore $ra
		addi $sp , $sp , 4 # restore restore restore $sp
		jr $ra # return

finished:
		li $v0, 4
		la $a0, finishedMES
		syscall

		li $v0, 10
		syscall
