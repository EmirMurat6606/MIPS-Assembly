.data
kleur: .asciiz "Geef een kleurcode op in aRGB formaat: "
kolom: .asciiz "Geef een kolomnummer op:"
rij: .asciiz "Geef een rijnummer op:"

# Kleur coderingen in aRGB formaat
rood: .word 0xFFFF0000
geel: .word 0xFFFFFF00
paars: .word 0x00671D9D

.text
main:
li $t0, 0         # Start rijnummer
li $t1, 0         # Start kolomnummer
lw $s0, rood      # Zet kleurcode rood in $s0
lw $s1, geel      # Zet kleurcode geel in $s1

   main_loop: 
   
   # Volgende rij indien kolomnommer >= 32
   bge $t1, 32, rij_jump
   # Beïndig programma indien rijnummer >= 16
   bge $t0, 16, exit
   
   # Kleur de pixel
   jal Kleur_pixel
   
   # Ga terug naar main_loop
   j main_loop
   
   
# Overgang van rij naar rij
rij_jump:
addi $t0, $t0, 1
li $t1, 0
j main_loop


Kleur_pixel: 

 sw $fp, 0($sp)         # Sla oude frame pointer op
 move $fp, $sp          # Nieuwe frame pointer => top v/d stack
 subu $sp, $sp, 16      # Alloceer plaats op de stack 
 sw $ra, -4($fp)        # Sla $ra op in stack frame
 sw $t0, -8($fp)        # Sla $t0(rijnummer) op in stack frame
 sw $t1, -12($fp)       # Sla $t1(kolomnummer) op in stakc frame
 
 # Condities om geel te kleuren
 beq $t0, 15, yellow
 beq $t0, 0, yellow
 beq $t1, 0, yellow
 beq $t1, 31, yellow
 # Niet geel? => rood
 j red   

  red:
  move $a1, $t0       # Plaats waarde $t0 in $a1 (rij)
  move $a2, $t1       # Plaats waarde $t1 in $a2 (kolom)
  jal coordinaat      # Spring naar coordinaat functie
  move $t0, $v0       # Kleur pixel rood
  sw $s0, 0($t0)      # Plaats kleur rood op pixel positie
  j exit_procedure
 
  yellow:
  move $a1, $t0       # Plaats waarde $t0 in $a1
  move $a2, $t1       # Plaats waarde $t1 in $a2
  jal coordinaat      # Spring naar coordinaat functie
  move $t0, $v0       # Kleur pixel geel
  sw $s1, 0($t0)      # Plaats kleur geel op pixel positie
  j exit_procedure
  
  exit_procedure:
  lw $ra, -4($fp)  
  lw $t0, -8($fp)
  lw $t1, -12($fp)
  addi $t1, $t1, 1
  move $sp, $fp
  jr $ra
   
coordinaat:

 sw $fp, 0($sp)         # Vorige frame pointer naar 0($sp)
 move $fp, $sp          # Frame pointer naar top van stack
 sw $ra, -4($fp)        # Plaats $ra in frame 
 subu $sp, $sp, 16      # Alloceer plaats op de stack 
 sw $t0, -8($fp)        # Sla rijnummer op in frame
 sw $t1, -12($fp)       # Sla kolomnummer op in frame
 
 mul $t0, $a1, 32       # Vermenigvuldig rij met 32 (bepaalt rij)
 add $t0, $t0, $a2      # Tel kolom op bij rij (bepaalt kolom in rij)
 sll $t0, $t0, 2        # Vermenigvuldig geheel met 4 (elke pixel 4 bytes)
 addu $v0, $gp, $t0     # Vermeerder de $gp met $t0 
 
 lw $ra, -4($fp)        # Recupereer $ra
 lw $t0, -8($fp)        # Recupereer $t0
 lw $t1, -12($fp)       # Recupereer $t1
 move $sp, $fp          # Stack pointer naar oude frame pointer
 lw $fp, ($sp)          # Nieuwe stack pointer
 jr $ra                 # Ga naar $ra
 
exit:
 #Stop het programma
 li $v0, 10
 syscall
 
 


