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
get_adfgvx_coords:
	li $v0, -1
	li $v1, -1
	
	bltz $a0, get_adfgvx_coords_end
	bgt $a0, 5, get_adfgvx_coords_end
	
	bltz $a1, get_adfgvx_coords_end
	bgt $a1, 5, get_adfgvx_coords_end
	
	li $v0, 'A'
	li $v1, 'A'
	
	beq $a0, 0, get_adfgvx_coords_firstend
	li $v0, 'D'
	beq $a0, 1, get_adfgvx_coords_firstend
	li $v0, 'F'
	beq $a0, 2, get_adfgvx_coords_firstend
	li $v0, 'G'
	beq $a0, 3, get_adfgvx_coords_firstend
	li $v0, 'V'
	beq $a0, 4, get_adfgvx_coords_firstend
	li $v0, 'X'				 
get_adfgvx_coords_firstend:
	beq $a1 0, get_adfgvx_coords_end
	li $v1, 'D'
	beq $a1, 1, get_adfgvx_coords_end
	li $v1, 'F'
	beq $a1, 2, get_adfgvx_coords_end
	li $v1, 'G'
	beq $a1, 3, get_adfgvx_coords_end
	li $v1, 'V'
	beq $a1, 4, get_adfgvx_coords_end
	li $v1, 'X'
	 
get_adfgvx_coords_end:	
jr $ra

# Part II
search_adfgvx_grid:
	li $t0, 0
	li $t9, 6
	
search_adfgvx_grid_rowloop:
	li $t1, 0
search_adfgvx_grid_colloop:	
	mul $t2, $t0, $t9
	add $t2, $t2, $t1
	add $t2, $t2, $a0
	lb $t2, ($t2)
	
	beq $a1, $t2, search_adfgvx_grid_loop_rowend 
	
	addi $t1, $t1, 1
	blt $t1, $t9, search_adfgvx_grid_colloop
search_adfgvx_grid_loop_colend:
	addi $t0, $t0, 1
	blt $t0, $t9, search_adfgvx_grid_rowloop 
search_adfgvx_grid_loop_rowend:	
	li $v0, -1
	li $v1, -1
	
	bgt $t0, 5, search_adfgvx_grid_end
	bgt $t1, 5, search_adfgvx_grid_end 

	move $v0, $t0
	move $v1, $t1 
search_adfgvx_grid_end:
jr $ra

# Part III
map_plaintext:
	addi $sp, $sp, -20
    	sw $ra, ($sp)
    	sw $s0, 4($sp)
    	sw $s1, 8($sp)
    	sw $s2, 12($sp)
    	sw $s3, 16($sp)
    	
    	move $s0, $a0
    	move $s1, $a1
    	move $s2, $a2

	li $s3, 0
map_plaintext_loop:
	add $t0, $s3, $s1
	lb $t0, ($t0)
	
	beqz $t0, map_plaintext_loop_end 
	
	move $a0, $s0
	move $a1, $t0
	    	    	
    	jal search_adfgvx_grid
    	
    	move $a0, $v0
    	move $a1, $v1
    	
    	jal get_adfgvx_coords
    	
    	sb $v0, ($s2)
    	addi $s2, $s2, 1
    	sb $v1, ($s2)
    	addi $s2, $s2, 1
    	addi $s3, $s3, 1
   	
   	b map_plaintext_loop
    	
map_plaintext_loop_end:
    	
	lw $ra, ($sp)
    	lw $s0, 4($sp)
    	lw $s1, 8($sp)
    	lw $s2, 12($sp)
    	lw $s3, 16($sp)  	
    	addi $sp, $sp, 20
	jr $ra
jr $ra

# Part IV
swap_matrix_columns:
	li $v0, -1
	lw $t0, ($sp)
	
	blez $a1, swap_matrix_columns_loop_end
	blez $a2, swap_matrix_columns_loop_end
	bltz $a3, swap_matrix_columns_loop_end
	bge $a3, $a2, swap_matrix_columns_loop_end
	bltz $t0, swap_matrix_columns_loop_end
	bge $t0, $a2, swap_matrix_columns_loop_end
	
	li $v0, 0

	li $t1, 0
swap_matrix_columns_loop:

	mul $t2, $t1, $a2
	
	add $t3, $t2, $a3
	add $t3, $t3, $a0
	lb $t5, ($t3)
	
	add $t4, $t2, $t0
	add $t4, $t4, $a0
	lb $t6, ($t4)
	
	sb $t6, ($t3)
	sb $t5, ($t4)
	
	addi $t1, $t1, 1
	blt $t1, $a1, swap_matrix_columns_loop
swap_matrix_columns_loop_end:

jr $ra

# Part V
key_sort_matrix:
	lw $t0, ($sp)

	addi $sp, $sp, -24
    	sw $ra, 4($sp)
    	sw $s0, 8($sp)
    	sw $s1, 12($sp)
    	sw $s2, 16($sp)
    	sw $s3, 20($sp)
	move $s1, $t0
	move $s0, $a3
	
	li $s2, 0
key_sort_matrix_firstloop:
	li $s3, 0
key_sort_matrix_secondloop:
	mul $t1, $s3, $s1
	add $t1, $t1, $s0
	
	addi $t2, $s3, 1
	mul $t2, $t2, $s1
	add $t2, $t2, $s0
	
	beq $s1, 1, key_sort_matrix_sizeone
	lw $t3, ($t1)
	lw $t4, ($t2)
	b key_sort_matrix_sizedone
	
key_sort_matrix_sizeone:
	lbu $t3, ($t1)
	lbu $t4, ($t2)
key_sort_matrix_sizedone:

	ble $t3, $t4, key_sort_matrix_skipswap

	beq $s1, 1, key_sort_matrix_storesizeone
	sw $t4, ($t1)
	sw $t3, ($t2)
	b key_sort_matrix_storedone
	
key_sort_matrix_storesizeone:	
	sb $t4, ($t1)
	sb $t3, ($t2)

key_sort_matrix_storedone:
		
	move $a3, $s3
	addi $t9, $s3, 1
	sw $t9, ($sp)
	
	jal swap_matrix_columns
	    
key_sort_matrix_skipswap:	      
	sub $t0, $a2, $s2
	addi $t0, $t0, -1
	addi $s3, $s3, 1
	blt $s3, $t0, key_sort_matrix_secondloop
	
key_sort_matrix_secondloop_end:
	addi $s2, $s2, 1
	blt $s2, $a2, key_sort_matrix_firstloop
key_sort_matrix_firstloop_end:

	lw $ra, 4($sp)
    	lw $s0, 8($sp)
    	lw $s1, 12($sp)
    	lw $s2, 16($sp)
    	lw $s3, 20($sp)	
    	addi $sp, $sp, 24
jr $ra

# Part VI
transpose:
	li $v0, -1
	
	blez $a2, transpose_loop_rowdone 
	blez $a3, transpose_loop_rowdone
	
	li $v0, 0
	
	li $t0, 0
transpose_loop_row:
	li $t1, 0
transpose_loop_col:
	mul $t2, $t0, $a3
	add $t2, $t2, $t1
	add $t2, $t2, $a0
	
	
	mul $t3, $t1, $a2
	add $t3, $t3, $t0
	add $t3, $t3, $a1
	
	lb $t9, ($t2)
	sb $t9, ($t3)
	
	addi $t1, $t1, 1
	blt $t1, $a3, transpose_loop_col
transpose_loop_coldone:
	addi $t0, $t0, 1
	blt $t0, $a2, transpose_loop_row
transpose_loop_rowdone:	

jr $ra

# Part VII
encrypt:
	addi $sp, $sp, -36
    	sw $ra, ($sp)
    	sw $s0, 4($sp)
    	sw $s1, 8($sp)
    	sw $s2, 12($sp)
    	sw $s3, 16($sp)
	sw $s4, 20($sp)
    	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	li $t0, 0
encrypt_length_loop:
	add $t1, $a1, $t0
	lb $t1, ($t1)
	
	beqz $t1, encrypt_length_loopdone
	addi $t0, $t0, 1
	b encrypt_length_loop
encrypt_length_loopdone:
	sll $s4, $t0, 1
	
	li $t0, 0
encrypt_length_second_loop:
	add $t1, $a2, $t0
	lb $t1, ($t1)
	
	beqz $t1, encrypt_length_second_loopdone
	addi $t0, $t0, 1
	b encrypt_length_second_loop
encrypt_length_second_loopdone:
	move $s5, $t0
	
encrypt_ciphertextlength_loop:
	div $s4, $s5
	mfhi $t1
	beqz $t1, encrypt_ciphertextlength_loopdone
	addi $s4, $s4, 1
	b encrypt_ciphertextlength_loop
encrypt_ciphertextlength_loopdone:	
	mflo $s7
	
	move $a0, $s4
	li $v0, 9
	syscall
	
	move $s6, $v0

	li $t0, 0
	li $t2, '*'
encrypt_ciphertextasterisk_loop:
	add $t1, $s6, $t0
	sb $t2, ($t1)
	bgt $t0, $s4, encrypt_ciphertextasterisk_loopdone
	addi $t0, $t0, 1
	b encrypt_ciphertextasterisk_loop
encrypt_ciphertextasterisk_loopdone:	
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s6
	
	jal map_plaintext
	
	
	move $a0, $s6
	move $a1, $s7
	move $a2, $s5
	move $a3, $s2
	
	addi $sp, $sp, -4
	li $t0, 1
	sw $t0, 0($sp)
	jal key_sort_matrix
	addi $sp, $sp, 4
	
	move $a0, $s6
	move $a1, $s3
	move $a2, $s7
	move $a3, $s5
	
	jal transpose
	
	add $t0, $s3, $s4
	li $t1, 0
	sb $t1, ($t0)
	
	lw $ra, ($sp)
    	lw $s0, 4($sp)
    	lw $s1, 8($sp)
    	lw $s2, 12($sp)
    	lw $s3, 16($sp)  
    	lw $s4, 20($sp)
    	lw $s5, 24($sp)	
    	lw $s6, 28($sp)
    	lw $s7, 32($sp)
    	addi $sp, $sp, 36
jr $ra

# Part VIII
lookup_char:
	li $v0, -1
	li $v1, -1
	
	li $t0, 0
	beq $a1, 'A', lookup_char_determinesecond
	addi $t0, $t0, 1
	beq $a1, 'D', lookup_char_determinesecond
	addi $t0, $t0, 1
	beq $a1, 'F', lookup_char_determinesecond
	addi $t0, $t0, 1
	beq $a1, 'G', lookup_char_determinesecond
	addi $t0, $t0, 1
	beq $a1, 'V', lookup_char_determinesecond
	addi $t0, $t0, 1
	beq $a1, 'X', lookup_char_determinesecond
	
	b lookup_char_invalid
	
lookup_char_determinesecond:	
	li $t1, 0
	beq $a2, 'A', lookup_char_determined
	addi $t1, $t1, 1
	beq $a2, 'D', lookup_char_determined
	addi $t1, $t1, 1
	beq $a2, 'F', lookup_char_determined
	addi $t1, $t1, 1
	beq $a2, 'G', lookup_char_determined
	addi $t1, $t1, 1
	beq $a2, 'V', lookup_char_determined
	addi $t1, $t1, 1
	beq $a2, 'X', lookup_char_determined
	
	b lookup_char_invalid
	
lookup_char_determined:
	li $v0, 0
	
	li $t2, 6
	mul $t2, $t2, $t0
	add $t2, $t2, $t1
	add $t0, $a0, $t2
	
	lb $v1, ($t0)
	
lookup_char_invalid:	
	
jr $ra

# Part IX
string_sort:
	li $t0, 0
string_sort_length_loop:
	add $t1, $a0, $t0
	lb $t1, ($t1)
	
	beqz $t1, string_sort_length_loopdone
	addi $t0, $t0, 1
	b string_sort_length_loop
string_sort_length_loopdone:
	move $t9, $t0

	li $t0, 0
string_sort_firstloop:
	li $t1, 0
string_sort_secondloop:
	add $t2, $t1, $a0
	addi $t3, $t2, 1
	
	lb $t4, ($t2)
	lb $t5, ($t3)
	
	ble $t4, $t5, string_sort_secondloop_next
			
	sb $t4, ($t3)
	sb $t5, ($t2)
	
string_sort_secondloop_next:
	
	addi $t1, $t1, 1
	sub $t8, $t9, $t0
	addi $t8, $t8, -1
	blt $t1, $t8, string_sort_secondloop
string_sort_secondloopdone:
	addi $t0, $t0, 1
	blt $t0, $t9, string_sort_firstloop
string_sort_firstloopdone:	

jr $ra

# Part X
decrypt:
	addi $sp, $sp, -36
    	sw $ra, ($sp)
    	sw $s0, 4($sp)
    	sw $s1, 8($sp)
    	sw $s2, 12($sp)
    	sw $s3, 16($sp)
	sw $s4, 20($sp)
    	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	
	#Move all arguements into s registes
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	#Find the length of the keyword and ssaves it to s4
	li $t0, 0
decrypt_kewordlength_loop:
	add $t1, $s2, $t0
	lb $t1, ($t1)
	beq $t1, 0, decrypt_kewordlength_loopdone
	addi $t0, $t0, 1
	b decrypt_kewordlength_loop
decrypt_kewordlength_loopdone:
	move $s4, $t0
	
	#Creates a keyword which will be sorted and saved to s5		
	move $a0, $s4
	li $v0, 9
	syscall 
	move $s5, $v0
	
	li $t0, 0
decrypt_copykeyword_loop:
	add $t1, $s2, $t0
	lb $t1, ($t1)
	add $t2, $s5, $t0	
	sb $t1, ($t2)
	addi $t0, $t0, 1
	blt $t0, $s4, decrypt_copykeyword_loop
	
	move $a0, $s5
	jal string_sort
	
	#Creates keyword indicies 
	move $a0, $s4
	li $v0, 9
	syscall
	
	#Stores heap keyword indicies into s6
	move $s6, $v0
	
	#heap_keyword_indices[i] = keyword.index_of(heap_keyword[i])
	li $t0, 0
decrypt_keywordindex_loop:	
	add $t3, $s5, $t0	
	lb $t3, ($t3)
	
	li $t2, 0
decrypt_keywordindexof_loop:
	add $t9, $s2, $t2
	lb $t9, ($t9)
	beq $t9, $t3, decrypt_keywordindexof_loopdone
	addi $t2, $t2, 1
	b decrypt_keywordindexof_loop
decrypt_keywordindexof_loopdone:

	add $t1, $s6, $t0
	sb $t2, ($t1)
	
	addi $t0, $t0, 1
	blt $t0, $s4, decrypt_keywordindex_loop
	
	#Finds the length of the cipher text and stores it to s7
	li $t0, 0
decrypt_cipherlength_loop:
	add $t1, $s1, $t0
	lb $t1, ($t1)
	beqz $t1, decrypt_cipherlength_loopdone
	addi $t0, $t0, 1
	b decrypt_cipherlength_loop
decrypt_cipherlength_loopdone:

	move $s7, $t0
	
	#Divides the cipher text length with the keyword length and stores it into s2
	div $s7, $s4
	mflo $s2
	
	#Creates a cipher text array and stores it into s5
	move $a0, $s7
	li $v0, 9
	syscall
	
	move $s5, $v0
	
	move $a0, $s1 #Source matrix
	move $a1, $s5 #matrix dest
	move $a2, $s4 #num rows
	move $a3, $s2 #num cols
	
	jal transpose
	
	move $a0, $s5 #matrix
	move $a1, $s2 #num rows
	move $a2, $s4 #num cols 
	move $a3, $s6 #key
	
	addi $sp, $sp, -4
	li $t0, 1
	sw $t0, 0($sp)	#elem size
	jal key_sort_matrix
	addi $sp, $sp, 4
	
	li $s4, 0
decrypt_loop:
	add $t1, $s5, $s4
	lb $a1, ($t1)
	lb $a2, 1($t1)
	move $a0, $s0
	
	jal lookup_char
	
	bltz $v0, decrypt_loopdone
	
	sb $v1, ($s3)
	addi $s3, $s3, 1
	addi $s4, $s4, 2
	b decrypt_loop
decrypt_loopdone:	
	sb $0, ($s3)
	
	lw $ra, ($sp)
    	lw $s0, 4($sp)
    	lw $s1, 8($sp)
    	lw $s2, 12($sp)
    	lw $s3, 16($sp)  
    	lw $s4, 20($sp)
    	lw $s5, 24($sp)	
    	lw $s6, 28($sp)
    	lw $s7, 32($sp)
    	addi $sp, $sp, 36
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
