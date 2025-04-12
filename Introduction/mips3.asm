.eqv last_case_num 2

.data
Jumptable: .space 12  

.text
main:
    li $v0, 5   
    syscall
    move $t0, $v0

    la $s0, Jumptable
    la $t1, case0
    sw  $t1, 0($s0)
    la $t1, case1
    sw $t1, 4($s0)
    la $t1, case2
    sw $t1, 8($s0)

    move $s1, $t0  

    blt $s1, $zero, default
    bgt $s1, last_case_num, default

    sll $t0, $s1, 2
    add $t0, $s0, $t0
    lw $t2, 0($t0)

    jr $t2

case0:
    li $t3, 9
    j end

case1:
    li $t3, 6
    j end

case2:
    li $t3, 8
    j end

default:
    li $t3, 7
    j end

end:
    la $a0, ($t3) 
    li $v0, 1
    syscall
     

     
    

             
        
     