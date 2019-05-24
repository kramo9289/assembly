.data
matrix_src: .asciiz "XDDDAAXAV*AXDFXDXFVFDDGFXGVVG*VDDF*"
matrix_dest: .asciiz "**********************************"

.text
.globl main
main:
la $a0, matrix_src
la $a1, matrix_dest
li $a2, 7
li $a3, 5
jal transpose
la $a0, matrix_dest
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
