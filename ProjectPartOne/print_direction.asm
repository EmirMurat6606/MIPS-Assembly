
.data
# Strings die moeten geprint worden
up: .asciiz " up\n"
down: .asciiz " down\n"
left: .asciiz " left\n"
right: .asciiz " right\n"
exception: .asciiz " “Unknown input! Valid inputs: z s q d x”\n"

.text

main:

  # Vraag een karakter op
  li $v0, 12  
  syscall
  move $t0, $v0

  # Ga naar procedure Karakter_input
  jal Karakter_input
  
  # Sleep 2 seconden
  li $v0, 32     
  la $a0, 2000
  syscall
  
  # Loop opnieuw 
  j main       

Karakter_input:
   
  sw $fp, 0($sp)        # Plaats oude frame pointer op $sp
  move $fp, $sp         # Maak nieuwe frame aan op top stack
  subu $sp, $sp, 8      # Alloceer plaats op de stack
  sw $ra, -4($fp)       # Plaats $ra in -4($fp)
 
  # Vergelijk karakter met direction karakters
  beq $t0,'z',up_z
  beq $t0,'s',down_s
  beq $t0,'q',left_q
  beq $t0,'d',right_d
  beq $t0,'x',exit
 
  j ongeldig           # Naar label ongeldig als karakter geen betekenis heeft
  
    # Karakter is z
    up_z:
    la $a0, up
    li $v0, 4
    syscall
    j verlaat_procedure
  
    # Karakter is s
    down_s:
    la $a0, down
    li $v0, 4
    syscall
    j verlaat_procedure
  
    # Karakter is q
    left_q:
    la $a0, left
    li $v0, 4
    syscall
    j verlaat_procedure

    # Karakter is d
    right_d:
    la $a0, right
    li $v0, 4
    syscall
    j verlaat_procedure

    ongeldig:
    # Geef aan dat karakter niet geldig is
    la $a0, exception   
    li $v0, 4
    syscall
               
    verlaat_procedure:
     lw $ra, -4($fp)        # Recupereer $ra
     move $sp, $fp          # Clear Stack Frame
     jr $ra                 # Ga terug naar main programma
    
# Sluit programma af 
exit:
li $v0, 10   
syscall


