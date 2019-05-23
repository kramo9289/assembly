# Kevin Ramos
# kevramos
# 111019436

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
init_game:

    addi $sp, $sp, -20
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0	#Saves the arguements to s registers 
    move $s1, $a1
    move $s2, $a2
    
    li $v0, 13	#v0 set to 13 to open file		
    li $a1, 0	#Flag is read
    		#a0 already contains the file name
    li $a2, 0		
    syscall	#Opens a file and sets the file description to v0
    
    bltz $v0, init_game_end	#If it returns negative then there was an error
    
    move $s3, $v0	#Saves the file description to s3			
    move $a0, $s3	#Moves the file descriptoion to a0
    
    #Fill a1 with the input buffer
    addi $sp, $sp, -6
    addi $a1, $sp, 0
    li $a2, 6		#Reads 6 characters off the file (including )
    li $v0, 14		#v0 is set to 14 to read the file
    syscall		#sets v0 to the number of characters read
        
    bltz $v0, init_game_end	#If it returns negative then there was an error
    
    
    #The following takes the first two numbers from the file which is the row and cols and stores them into the map struct
    lb $t1, ($sp)
    addi $t1, $t1, -48
    li $t2, 10
    mul $t2, $t2, $t1
    
    lb $t1, 1($sp)
    addi $t1, $t1, -48
    add $t2, $t2, $t1
    
    sb $t2, ($s1)
    move $t9, $t2	#t9 will hold the value of rows
    
    lb $t1, 3($sp)
    addi $t1, $t1, -48
    li $t2, 10
    mul $t2, $t2, $t1
    
    lb $t1, 4($sp)
    addi $t1, $t1, -48
    add $t2, $t2, $t1
    
    sb $t2, 1($s1)
    move $t8, $t2	#t8 will hold the number of cols
    
    addi $sp, $sp, 6	#Finish using stack for 6 characters
    
    
    addi $sp, $sp, -1 	#Uses the stack to store 1 byte
    addi $t0, $s1, 2	#Moves the map struct by 2
    
    li $t1, 0		#Counter for outer loop (i)
init_game_loop:
    li $t2, 0		#Nested forloop counter (j)
init_game_nestedloop:
    #Gets one byte of the file and stores it in sp
    addi $a1, $sp, 0
    li $a2, 1		#Reads 1 character off the file (including /n)
    li $v0, 14		#v0 is set to 14 to read the file
    syscall		#sets v0 to the number of characters read
    bltz $v0, init_game_end	#If it returns negative then there was an error
    
    lb $t3, ($sp)	#Loads all characters and changes their flags to hidden (msb bit is 1)
   
    beq $t3, '@', init_game_codesalot
init_game_codesalotreturns:
        
    addi $t3, $t3, 128 
    
    mul $t4, $t8, $t1	#base + (i x C + j)
    add $t4, $t4, $t2
    add $t4, $t4, $t0
    
    sb $t3, ($t4)	#Stores the byte in the map struct
    
    addi $t2, $t2, 1
    blt $t2, $t8, init_game_nestedloop
init_game_nestedloopend:

    #Calls to read the extra /n at the end of each line in the text file
    addi $a1, $sp, 0
    li $a2, 1		#Reads 1 character off the file (including /n)
    li $v0, 14		#v0 is set to 14 to read the file
    syscall		#sets v0 to the number of characters read
    bltz $v0, init_game_end	#If it returns negative then there was an error	

    addi $t1, $t1, 1
    blt $t1, $t9, init_game_loop

    j init_game_loopend	
    
init_game_codesalot:
    sb $t1, ($s2)
    sb $t2, 1($s2)
    j init_game_codesalotreturns
    
init_game_loopend: 
    
    addi $sp, $sp, 1	#Adds one more space on the stack
    addi $sp, $sp, -2 
    
    #Will read the last two health characters and store it in the player struct
    addi $a1, $sp, 0
    li $a2, 2		#Reads 2 character off the file (including /n)
    li $v0, 14		#v0 is set to 14 to read the file
    syscall		#sets v0 to the number of characters read
    bltz $v0, init_game_end	#If it returns negative then there was an error
    
    #Loads the health and converts it to decimal and stores it in the player struck
    lb $t0, ($sp)
    addi $t0, $t0, -48
    li $t9, 10
    mul $t0, $t0, $t9
    
    lb $t1, 1($sp)
    addi $t1, $t1, -48
    add $t0, $t0, $t1
    
    sb $t0, 2($s2)
    
    #stores 0 for the amount of coins
    sb $0, 3($s2)
    
    addi $sp, $sp, 2	#Restores the stack
    
    
init_game_end:
    #CLoses the read file
    li $v0, 16
    move $a0, $s3
    syscall
    
    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)  
    addi $sp, $sp, 20
jr $ra


# Part II
is_valid_cell:
    li $v0, -1		
    lbu $t0, ($a0)	#Loads row from map struct
    lbu $t1, 1($a0)	#Loads col from map struck
    
    bltz $a1, is_valid_cellend	#row < 0
    bge $a1, $t0, is_valid_cellend	#row >= map struct row
    bltz $a2, is_valid_cellend 	#col < 0
    bge $a2, $t1, is_valid_cellend	#col >= map struct col
   
    li $v0, 0
is_valid_cellend:
jr $ra


# Part III
get_cell:
    addi $sp, $sp, -16
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    #Moves the arguments into s registers    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    #Checks to see if the cell is vaild or not
    jal is_valid_cell
    bltz $v0, get_cellend
    
    #Gets the number of col that will be used to find the cell 
    lbu $t0, 1($s0)
    
    # base + (row * COL + col)
    mul $t0, $t0, $s1
    add $t0, $t0, $s2
    
    #Moves the map struct to the map portion and loads the byte into v0
    addi $t1, $s0, 2
    add $t1, $t1, $t0
    
    lbu $v0, ($t1)
get_cellend:
    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp) 
    addi $sp, $sp, 16
jr $ra


# Part IV
set_cell:
    addi $sp, $sp, -20
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    #Moves the arguments into s registers    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    
    #Checks to see if the cell is valid
    jal is_valid_cell
    bltz $v0, set_cellend
    
    #Gets the number of col that will be used to find the cell 
    lbu $t0, 1($s0)
    
    # base + (row * COL + col)
    mul $t0, $t0, $s1
    add $t0, $t0, $s2
    
    #Moves the map struct to the map portion and loads the byte into v0
    addi $t1, $s0, 2
    add $t1, $t1, $t0
   
    #Stores the character at the position
    sb $s3, ($t1)
    
set_cellend:

    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)  
    addi $sp, $sp, 20
jr $ra


# Part V
reveal_area:
    addi $sp, $sp, -16
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    #Moves the arguments into s registers
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    addi $a1, $s1, -1
    addi $a2, $s2, -1
    jal get_cell
    
    bltz $v0, reveal_area2
    blt $v0, 128, reveal_area2
    
    addi $a1, $s1, -1
    addi $a2, $s2, -1
    addi $a3, $v0, -128
    jal set_cell

reveal_area2:
    move $a0, $s0
    addi $a1, $s1, -1
    addi $a2, $s2, 0
    jal get_cell
    
    bltz $v0, reveal_area3
    blt $v0, 128, reveal_area3
    
    addi $a1, $s1, -1
    addi $a2, $s2, 0
    addi $a3, $v0, -128
    jal set_cell

reveal_area3:
    move $a0, $s0
    addi $a1, $s1, -1
    addi $a2, $s2, 1
    jal get_cell
    
    bltz $v0, reveal_area4
    blt $v0, 128, reveal_area4
    
    addi $a1, $s1, -1
    addi $a2, $s2, 1
    addi $a3, $v0, -128
    jal set_cell
    
reveal_area4:
    move $a0, $s0
    addi $a1, $s1, 0
    addi $a2, $s2, -1
    jal get_cell
    
    bltz $v0, reveal_area5
    blt $v0, 128, reveal_area5
    
    addi $a1, $s1, 0
    addi $a2, $s2, -1
    addi $a3, $v0, -128
    jal set_cell

reveal_area5:
    move $a0, $s0
    addi $a1, $s1, 0
    addi $a2, $s2, 0
    jal get_cell
    
    bltz $v0, reveal_area6
    blt $v0, 128, reveal_area6
    
    addi $a1, $s1, 0
    addi $a2, $s2, 0
    addi $a3, $v0, -128
    jal set_cell
    
reveal_area6:
    move $a0, $s0
    addi $a1, $s1, 0
    addi $a2, $s2, 1
    jal get_cell
    
    bltz $v0, reveal_area7
    blt $v0, 128, reveal_area7
    
    addi $a1, $s1, 0
    addi $a2, $s2, 1
    addi $a3, $v0, -128
    jal set_cell
    
reveal_area7:
    move $a0, $s0
    addi $a1, $s1, 1
    addi $a2, $s2, -1
    jal get_cell
    
    bltz $v0, reveal_area8
    blt $v0, 128, reveal_area8
    
    addi $a1, $s1, 1
    addi $a2, $s2, -1
    addi $a3, $v0, -128
    jal set_cell
    
reveal_area8:
    move $a0, $s0
    addi $a1, $s1, 1
    addi $a2, $s2, 0
    jal get_cell
    
    bltz $v0, reveal_area9
    blt $v0, 128, reveal_area9
    
    addi $a1, $s1, 1
    addi $a2, $s2, 0
    addi $a3, $v0, -128
    jal set_cell
    
reveal_area9:      
    move $a0, $s0 
    addi $a1, $s1, 1
    addi $a2, $s2, 1
    jal get_cell
    
    bltz $v0, reveal_areaend
    blt $v0, 128, reveal_areaend
    
    addi $a1, $s1, 1
    addi $a2, $s2, 1
    addi $a3, $v0, -128
    jal set_cell
    
reveal_areaend:
    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp) 
    addi $sp, $sp, 16	
jr $ra

# Part VI
get_attack_target:
    addi $sp, $sp, -16
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    #Moves the arguments into s registers
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    li $v0, -1
    
    beq $s2, 'U', get_attack_targetup
    beq $s2, 'D', get_attack_targetdown
    beq $s2, 'L', get_attack_targetleft
    beq $s2, 'R', get_attack_targetright
    
    b get_attack_targetend

get_attack_targetup:
    lbu $a1, ($s1)
    addi $a1, $a1, -1
    lbu $a2, 1($s1)
    
    jal get_cell
    bltz $v0, get_attack_targetend
    
    beq $v0, '/', get_attack_targetend
    beq $v0, 'm', get_attack_targetend
    beq $v0, 'B', get_attack_targetend
    
    li $v0, -1
    b get_attack_targetend

get_attack_targetdown:
    lbu $a1, ($s1)
    addi $a1, $a1, 1
    lbu $a2, 1($s1)
    
    jal get_cell
    bltz $v0, get_attack_targetend
    
    beq $v0, '/', get_attack_targetend
    beq $v0, 'm', get_attack_targetend
    beq $v0, 'B', get_attack_targetend
    
    li $v0, -1
    b get_attack_targetend

get_attack_targetleft:
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    addi $a2, $a2, -1
    
    jal get_cell
    bltz $v0, get_attack_targetend
    
    beq $v0, '/', get_attack_targetend
    beq $v0, 'm', get_attack_targetend
    beq $v0, 'B', get_attack_targetend
    
    li $v0, -1
    b get_attack_targetend

get_attack_targetright:        
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    addi $a2, $a2, 1
    
    jal get_cell
    bltz $v0, get_attack_targetend
    
    beq $v0, '/', get_attack_targetend
    beq $v0, 'm', get_attack_targetend
    beq $v0, 'B', get_attack_targetend
    
    li $v0, -1
    
get_attack_targetend:

    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp) 
    addi $sp, $sp, 16	
jr $ra


# Part VII
complete_attack:
    addi $sp, $sp, -20
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    #Moves the arguments into s registers
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    
    move $a1, $s2
    move $a2, $s3
    jal get_cell
    
    beq $v0, 'B', complete_attackboss
    beq $v0, 'm', complete_attackminion
    beq $v0, '/', complete_attackdoor
    
complete_attackboss:
    lb $t0, 2($s1)
    addi $t0, $t0, -2
    sb $t0, 2($s1)
    
    bgtz $t0, complete_attackbossnotdead
    
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    li $a3, 'X'
    jal set_cell
    
complete_attackbossnotdead:
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    li $a3, '*'
    
    jal set_cell
    
    b complete_attackend

complete_attackminion:
    lb $t0, 2($s1)
    addi $t0, $t0, -1
    sb $t0, 2($s1)
    
    bgtz $t0, complete_attackminionnotdead
    
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    li $a3, 'X'
    jal set_cell
    
complete_attackminionnotdead:
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    li $a3, '$'
    
    jal set_cell
    
    b complete_attackend
    
complete_attackdoor:  
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    li $a3, '.'
    
    jal set_cell
  
complete_attackend:    
    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp) 
    lw $s3, 16($sp) 
    addi $sp, $sp, 20
jr $ra


# Part VIII
monster_attacks:
    addi $sp, $sp, -16
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    
    move $s0, $a0
    move $s1, $a1
    
    li $s2, 0
    
    lbu $a1, ($s1)
    addi $a1, $a1, -1
    lbu $a2, 1($s1)
    jal get_cell
    
    beq $v0, 'B', monster_attacksupboss
    beq $v0, 'm', monster_attacksupminion
    b monster_attacksdown
    
monster_attacksupboss:
    addi $s2, $s2, 2	   	
    b monster_attacksdown
monster_attacksupminion:   
    addi $s2, $s2, 1	   	
    
monster_attacksdown:
    move $a0, $s0
    lbu $a1, ($s1)
    addi $a1, $a1, 1
    lbu $a2, 1($s1)
    jal get_cell
    
    beq $v0, 'B', monster_attacksdownboss
    beq $v0, 'm', monster_attacksdownminion
    b monster_attacksleft
    
monster_attacksdownboss:
    addi $s2, $s2, 2	   	
    b monster_attacksleft
monster_attacksdownminion:   
    addi $s2, $s2, 1


monster_attacksleft:
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    addi $a2, $a2, -1
    jal get_cell
    
    beq $v0, 'B', monster_attacksleftboss
    beq $v0, 'm', monster_attacksleftminion
    b monster_attacksright
    
monster_attacksleftboss:
    addi $s2, $s2, 2	   	
    b monster_attacksright
monster_attacksleftminion:   
    addi $s2, $s2, 1


monster_attacksright:    
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    addi $a2, $a2, 1
    jal get_cell
    
    beq $v0, 'B', monster_attacksrightboss
    beq $v0, 'm', monster_attacksrightminion
    b monster_attacksend
    
monster_attacksrightboss:
    addi $s2, $s2, 2	   	
    b monster_attacksend
monster_attacksrightminion:   
    addi $s2, $s2, 1
    
monster_attacksend: 
    move $v0, $s2
       
    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
jr $ra


# Part IX
player_move:
    addi $sp, $sp, -20
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    #Moves the arguments into s registers
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    
    jal monster_attacks
    
    lb $t0, 2($s1)
    sub $t0, $t0, $v0
    sb $t0, 2($s1)
    li $v0, 0
    
    blez, $t0, player_movedead
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    
    jal get_cell
    
    beq $v0, '.', player_movefloor
    beq $v0, '$', player_movecoin
    beq $v0, '*', player_movegem
    beq $v0, '>', player_moveexit
    
    b player_moveend
    
player_movefloor:
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    li $a3, '.'
    
    jal set_cell
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    li $a3, '@'
    
    jal set_cell
    
    sb $s2, ($s1)
    sb $s3, 1($s1)
    
    li $v0, 0
    
    b player_moveend
    
player_movecoin:
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    li $a3, '.'
    
    jal set_cell
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    li $a3, '@'
    
    jal set_cell
    
    sb $s2, ($s1)
    sb $s3, 1($s1)
    
    lbu $t0, 3($s1)
    addi $t0, $t0, 1
    sb $t0, 3($s1)
    
    li $v0, 0
    
    b player_moveend


player_movegem:
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    li $a3, '.'
    
    jal set_cell
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    li $a3, '@'
    
    jal set_cell
    
    sb $s2, ($s1)
    sb $s3, 1($s1)
    
    lbu $t0, 3($s1)
    addi $t0, $t0, 5
    sb $t0, 3($s1)
    
    li $v0, 0
    
    b player_moveend	


player_moveexit:
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    li $a3, '.'
    
    jal set_cell
    
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    li $a3, '@'
    
    jal set_cell
    
    sb $s2, ($s1)
    sb $s3, 1($s1)
    
    li $v0, -1
    
    b player_moveend

    
player_movedead:    
    move $a0, $s0
    lbu $a1, ($s1)
    lbu $a2, 1($s1)
    li $a3, 'X'
    jal set_cell
    
player_moveend:    
    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp) 
    lw $s3, 16($sp) 
    addi $sp, $sp, 20
jr $ra


# Part X
player_turn:
    addi $sp, $sp, -16
    sw $ra, ($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    
    beq $s2, 'U', player_turnup
    beq $s2, 'D', player_turndown
    beq $s2, 'L', player_turnleft
    beq $s2, 'R', player_turnright
    
    li $v0, -1
    b player_turnend
    
player_turnup:
   lbu $a1, ($s1)
   addi $a1, $a1, -1
   lbu $a2, 1($s1)
   
   jal get_cell
   
   bltz $v0, player_turnendzero
   beq $v0, '#', player_turnendzero
   
   move $a0, $s0
   move $a1, $s1
   move $a2, $s2
   
   jal get_attack_target
   
   bltz $v0, player_turnupmove
   
   move $a0, $s0
   move $a1, $s1
   lbu  $a2, ($s1)
   addi $a2, $a2, -1
   lbu $a3, 1($s1)
   
   jal complete_attack
   
   b player_turnendzero
   
player_turnupmove: 
   move $a0, $s0
   move $a1, $s1
   lbu $a2, ($s1)
   addi $a2, $a2, -1
   lbu $a3, 1($s1)
   
   jal player_move
   
   b player_turnend
    

player_turndown:
   lbu $a1, ($s1)
   addi $a1, $a1, 1
   lbu $a2, 1($s1)
   
   jal get_cell
   
   bltz $v0, player_turnendzero
   beq $v0, '#', player_turnendzero
   
   move $a0, $s0
   move $a1, $s1
   move $a2, $s2
   
   jal get_attack_target
   
   bltz $v0, player_turndownmove
   
   move $a0, $s0
   move $a1, $s1
   lbu $a2, ($s1)
   addi $a2, $a2, 1
   lbu $a3, 1($s1)
   
   jal complete_attack
   
   b player_turnendzero
   
player_turndownmove: 
   move $a0, $s0
   move $a1, $s1
   lbu $a2, ($s1)
   addi $a2, $a2, 1
   lbu $a3, 1($s1)
   
   jal player_move
   
   b player_turnend

player_turnleft:
   lbu $a1, ($s1)
   lbu $a2, 1($s1)
   addi $a2, $a2, -1
   
   jal get_cell
   
   bltz $v0, player_turnendzero
   beq $v0, '#', player_turnendzero
   
   move $a0, $s0
   move $a1, $s1
   move $a2, $s2
   
   jal get_attack_target
   
   bltz $v0, player_turnleftmove
   
   move $a0, $s0
   move $a1, $s1
   lbu $a2, ($s1)
   lbu $a3, 1($s1)
   addi $a3, $a3, -1
   
   jal complete_attack
   
   b player_turnendzero
   
player_turnleftmove: 
   move $a0, $s0
   move $a1, $s1
   lbu $a2, ($s1)
   lbu $a3, 1($s1)
   addi $a3, $a3, -1
   
   jal player_move
   
   b player_turnend


player_turnright:
   lbu $a1, ($s1)
   lbu $a2, 1($s1)
   addi $a2, $a2, 1
   
   jal get_cell
   
   bltz $v0, player_turnendzero
   beq $v0, '#', player_turnendzero
   
   move $a0, $s0
   move $a1, $s1
   move $a2, $s2
   
   jal get_attack_target
   
   bltz $v0, player_turnrightmove
   
   move $a0, $s0
   move $a1, $s1
   lbu $a2, ($s1)
   lbu $a3, 1($s1)
   addi $a3, $a3, 1
   
   jal complete_attack
   
   b player_turnendzero
   
player_turnrightmove: 
   move $a0, $s0
   move $a1, $s1
   lbu $a2, ($s1)
   lbu $a3, 1($s1)
   addi $a3, $a3, 1
   
   jal player_move
   
   b player_turnend
   
    
player_turnendzero:
    li $v0, 0    
player_turnend:
    lw $ra, ($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp) 
    addi $sp, $sp, 16
jr $ra


# Part XI
flood_fill_reveal:
    addi $sp, $sp, -32
    sw $ra, ($sp)
    sw $fp, 4($sp)
    sw $s0, 8($sp)
    sw $s1, 12($sp)
    sw $s2, 16($sp)
    sw $s3, 20($sp)
    sw $s4, 24($sp)
    sw $s5, 28($sp)
    
    
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    
    li $v0, -1
    lbu $t0, ($s0)
    lbu $t1, 1($s0)
    
    bltz $s1, flood_fill_revealend
    bltz $s2, flood_fill_revealend
    bge $s1, $t0, flood_fill_revealend
    bge $s2, $t1, flood_fill_revealend
    
    li $v0, 0
    
    move $fp, $sp
    
    addi $sp, $sp, -4
    sw $s1, ($sp)
    addi $sp, $sp, -4
    sw $s2, ($sp)
    
flood_fill_while:
     lw $s4, ($sp)	 # s4=col = $sp.pop()  and  s5=row = $sp.pop()
     addi $sp, $sp, 4
     lw $s5, ($sp)
     addi $sp, $sp, 4
     
     
     move $a0, $s0	#Gets the cell of row col
     move $a1, $s5
     move $a2, $s4
     
     jal get_cell
     
     blt $v0, 128, flood_fill_alreadyvisible	#If it is not visible set it to visible
     addi $a3, $v0, -128
     move $a0, $s0
     move $a1, $s5
     move $a2, $s4
     
     jal set_cell
     
flood_fill_alreadyvisible:                 
     
     move $a0, $s0		#Gets the cell 
     addi $a1, $s5, -1
     addi $a2, $s4, 0
     
     jal get_cell
     
     beq $v0, 46, flood_fill_isfloorone		#If it is a floor check else move to the next offset
     beq $v0, 174, flood_fill_isfloorone
     
     b flood_fill_two
     
flood_fill_isfloorone:
     addi $t0, $s5, -1
     addi $t1, $s4, 0
     lbu $t2, 1($s0)
     mul $t0, $t0, $t2
     add $t0, $t0, $t1		
     
     li $t1, 32
     div $t0, $t1
     mflo $t9
     mfhi $t8
     
     sll $t9, $t9, 2
     
     add $t0, $t9, $s3
     lw $t1, ($t0)
     sllv $t3, $t1, $t8
     srl $t3, $t3, 31
     beq $t3, 1, flood_fill_two 
     
     li $t3, 1
     li $t4, 31
     sub $t4, $t4, $t8
     sllv $t3, $t3, $t4
     or $t1, $t1, $t3
     sw $t1, ($t0)
     
     addi $t0, $s5, -1
     addi $t1, $s4, 0
     
     addi $sp, $sp, -4
     sw $t0, ($sp)
     addi $sp, $sp, -4
     sw $t1, ($sp)
      
     
flood_fill_two:
     move $a0, $s0
     addi $a1, $s5, 1
     addi $a2, $s4, 0
     
     jal get_cell
     
     beq $v0, 46, flood_fill_isfloortwo
     beq $v0, 174, flood_fill_isfloortwo
     
     b flood_fill_three
     
flood_fill_isfloortwo:
     addi $t0, $s5, 1
     addi $t1, $s4, 0
     lbu $t2, 1($s0)
     mul $t0, $t0, $t2
     add $t0, $t0, $t1
     
     li $t1, 32
     div $t0, $t1
     mflo $t9
     mfhi $t8
     
     sll $t9, $t9, 2
     
     add $t0, $t9, $s3
     lw $t1, ($t0)
     sllv $t3, $t1, $t8
     srl $t3, $t3, 31
     beq $t3, 1, flood_fill_three
     
     li $t3, 1
     li $t4, 31
     sub $t4, $t4, $t8
     sllv $t3, $t3, $t4
     or $t1, $t1, $t3
     sw $t1, ($t0)
     
     addi $t0, $s5, 1
     addi $t1, $s4, 0
     
     addi $sp, $sp, -4
     sw $t0, ($sp)
     addi $sp, $sp, -4
     sw $t1, ($sp)

flood_fill_three:
     move $a0, $s0
     addi $a1, $s5, 0
     addi $a2, $s4, -1
     
     jal get_cell
     
     beq $v0, 46, flood_fill_isfloorthree
     beq $v0, 174, flood_fill_isfloorthree
     
     b flood_fill_four
     
flood_fill_isfloorthree:
     addi $t0, $s5, 0
     addi $t1, $s4, -1
     lbu $t2, 1($s0)
     mul $t0, $t0, $t2
     add $t0, $t0, $t1
     
     li $t1, 32
     div $t0, $t1
     mflo $t9
     mfhi $t8
     
     sll $t9, $t9, 2
     
     add $t0, $t9, $s3
     lw $t1, ($t0)
     sllv $t3, $t1, $t8
     srl $t3, $t3, 31
     beq $t3, 1, flood_fill_four 
     
     li $t3, 1
     li $t4, 31
     sub $t4, $t4, $t8
     sllv $t3, $t3, $t4
     or $t1, $t1, $t3
     sw $t1, ($t0)
     
     addi $t0, $s5, 0
     addi $t1, $s4, -1
     
     addi $sp, $sp, -4
     sw $t0, ($sp)
     addi $sp, $sp, -4
     sw $t1, ($sp)


flood_fill_four:    
     move $a0, $s0
     addi $a1, $s5, 0
     addi $a2, $s4, 1
     
     jal get_cell
     
     beq $v0, 46, flood_fill_isfloorfour
     beq $v0, 174, flood_fill_isfloorfour
     
     b flood_fill_checkwhile
     
flood_fill_isfloorfour:
     addi $t0, $s5, 0
     addi $t1, $s4, 1
     lbu $t2, 1($s0)
     mul $t0, $t0, $t2
     add $t0, $t0, $t1
     
     li $t1, 32
     div $t0, $t1
     mflo $t9
     mfhi $t8
     
     sll $t9, $t9, 2
     
     add $t0, $t9, $s3
     lw $t1, ($t0)
     sllv $t3, $t1, $t8
     srl $t3, $t3, 31
     beq $t3, 1, flood_fill_checkwhile 
     
     li $t3, 1
     li $t4, 31
     sub $t4, $t4, $t8
     sllv $t3, $t3, $t4
     or $t1, $t1, $t3
     sw $t1, ($t0)
     
     addi $t0, $s5, 0
     addi $t1, $s4, 1
     
     addi $sp, $sp, -4
     sw $t0, ($sp)
     addi $sp, $sp, -4
     sw $t1, ($sp)             
 
flood_fill_checkwhile:
     bne $fp, $sp, flood_fill_while
    
flood_fill_revealend:    
    lw $ra, ($sp)
    lw $fp, 4($sp)
    lw $s0, 8($sp)
    lw $s1, 12($sp) 
    lw $s2, 16($sp) 
    lw $s3, 20($sp)
    lw $s4, 24($sp) 
    lw $s5, 28($sp)  
    addi $sp, $sp, 32
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
