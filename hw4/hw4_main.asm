.data
map_filename: .asciiz "map1.txt"
# num words for map: 45 = (num_rows * num_cols + 2) // 4 
# map is random garbage initially
.asciiz "Don't touch this region of memory"
map: .word 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 0x632DEF01 0xAB101F01 0xABCDEF01 0x00000201 0x22222222 0xA77EF01 0x88CDEF01 0x90CDEF01 0xABCD2212 
.asciiz "Don't touch this"
# player struct is random garbage initially
player: .word 0x2912FECD
.asciiz "Don't touch this either"
# visited[][] bit vector will always be initialized with all zeroes
# num words for visited: 6 = (num_rows * num*cols) // 32 + 1
visited: .word 0 0 0 0 0 0 
.asciiz "Really, please don't mess with this string"

welcome_msg: .asciiz "Welcome to MipsHack! Prepare for adventure!\n"
pos_str: .asciiz "Pos=["
health_str: .asciiz "] Health=["
coins_str: .asciiz "] Coins=["
your_move_str: .asciiz " Your Move: "
you_won_str: .asciiz "Congratulations! You have defeated your enemies and escaped with great riches!\n"
you_died_str: .asciiz "You died!\n"
you_failed_str: .asciiz "You have failed in your quest!\n"
space_str: .asciiz " "
comma_str: .asciiz ","
endbracket_str: .asciiz "]"
newline_str: .asciiz "\n"

.text
print_map:
la $t0, map  # the function does not need to take arguments

lbu $t1, ($t0)
lbu $t2, 1($t0)
addi $t0, $t0, 2

li $t8, 0
print_maploop:
li $t9, 0

print_mapnested:
mul $t5, $t8, $t2
add $t5, $t5, $t9

add $t7, $t0, $t5
lbu $a0, ($t7)
bgt $a0, 128, print_mapnestedinvis 

li $v0, 11
syscall
b print_mapnestednext

print_mapnestedinvis:
la $a0, space_str
li $v0, 4
syscall

print_mapnestednext:
addi $t9, $t9, 1
blt $t9, $t2, print_mapnested

la $a0, newline_str
li $v0, 4
syscall

addi $t8, $t8, 1
blt $t8, $t1, print_maploop

jr $ra

print_player_info:
# the idea: print something like "Pos=[3,14] Health=[4] Coins=[1]"
la $t0, player
la $a0, pos_str
li $v0, 4
syscall
lbu $a0, ($t0)
li $v0, 1
syscall
la $a0, comma_str
li $v0, 4
syscall
lbu $a0, 1($t0)
li $v0, 1
syscall
la $a0, health_str
li $v0, 4
syscall
lb $a0, 2($t0)
li $v0, 1
syscall
la $a0, coins_str
li $v0, 4
syscall
lbu $a0, 3($t0)
li $v0, 1
syscall
la $a0, endbracket_str
li $v0, 4
syscall
jr $ra


.globl main
main:
la $a0, welcome_msg
li $v0, 4
syscall

# fill in arguments
la $a0, map_filename
la $a1, map
la $a2, player
jal init_game

# fill in arguments
la $a0, map
la $t0, player
lb $a1, ($t0)
lb $a2, 1($t0)

jal reveal_area

li $s0, 0  # move = 0

game_loop:  # while player is not dead and move == 0:

jal print_map # takes no args

jal print_player_info # takes no args

# print prompt
la $a0, your_move_str
li $v0, 4
syscall

li $v0, 12  # read character from keyboard
syscall
move $s1, $v0  # $s1 has character entered
li $s0, 0  # move = 0

li $a0, '\n'
li $v0 11
syscall

# handle input: w, a, s or d
# map w, a, s, d  to  U, L, D, R and call player_turn()
bne $s1, 'w', check_a
la $a0, map
la $a1, player
li $a2, 'U'
jal player_turn
move $s0, $v0

b game_loop_check

check_a:
bne $s1, 'a', check_s
la $a0, map
la $a1, player
li $a2, 'L'
jal player_turn
move $s0, $v0

b game_loop_check

check_s:
bne $s1, 's', check_d
la $a0, map
la $a1, player
li $a2, 'D'
jal player_turn
move $s0, $v0

b game_loop_check

check_d:
bne $s1, 'd', check_r
la $a0, map
la $a1, player
li $a2, 'R'
jal player_turn
move $s0, $v0

b game_loop_check

check_r:
bne $s1, 'r', game_loop_check
la $a0, map
la $t0, player
lb $a1, ($t0)
lb $a2, 1($t0)
la $a3, visited

jal flood_fill_reveal


game_loop_check:
# if move == 0, call reveal_area()  Otherwise, exit the loop.
bnez $s0, game_over

la $a0, map
la $t0, player
lb $a1, ($t0)
lb $a2, 1($t0)

jal reveal_area

beqz $s0, game_loop_checkhealth

game_loop_checkhealth:
la $t0, player
lb $t0, 2($t0)
bgtz $t0, game_loop


game_over:
jal print_map
jal print_player_info
li $a0, '\n'
li $v0, 11
syscall

# choose between (1) player dead, (2) player escaped but lost, (3) player escaped and won
la $t0, player
lb $t1, 2($t0)
lbu $t2, 3($t0)

bgtz $t1, woncheck

b player_dead


woncheck:
bge $t2, 3, won

b failed

won:
la $a0, you_won_str
li $v0, 4
syscall
j exit

failed:
la $a0, you_failed_str
li $v0, 4
syscall
j exit

player_dead:
la $a0, you_died_str
li $v0, 4
syscall

exit:
jal print_player_info
li $v0, 10
syscall

.include "hw4.asm"
