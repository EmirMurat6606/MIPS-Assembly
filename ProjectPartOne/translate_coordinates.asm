.data
Rij_input: .asciiz "Geef het rijnummer in:"
Kolom_input: .asciiz "Geef het kolomnummer in:"
Ongeldig: .asciiz "Deze coordinaat is ongeldig"
.text

main:

# Vraag gebruiker om rijnummer
la $a0, Rij_input   
li $v0, 4               # Drukt een string af (Rij_input)
syscall
li $v0, 5               # Vraag gebruiker om rijnummer
syscall
move $a1, $v0           # Plaats rijnummer in $a1 

# Vraag gebruiker om kolomnummer
la $a0, Kolom_input   
li $v0, 4               # Drukt een string af(Kolom_input)
syscall
li $v0, 5               # Vraag gebruiker om kolomnummer
syscall
move $a2, $v0           # Plaats kolomnummer in $a2

# Coordinaat ongeldig?
bge $a1, 16, ongeldig
bge $a2, 32, ongeldig  

jal coordinaat          # Bereken de coordinaat (procedure coordinaat)

 # Print resultaat
la $a0, 0($v0)
li $v0, 34
syscall
j exit

coordinaat:
 sw $fp, 0($sp)        # Vorige frame pointer naar 0($sp)
 move $fp, $sp         # Frame pointer naar top van stack
 sw $ra, -4($fp)       # Plaats $ra in frame 

 mul $t0, $a1, 32      # Vermenigvuldig rij met 32 (bepaalt rij)
 add $t0, $t0, $a2     # Tel kolom op bij rij (bepaalt kolom in rij)
 sll $t0, $t0, 2       # Vermenigvuldig geheel met 4 (elke pixel 4 bytes)
 addu $v0, $gp, $t0    # Vermeerder de $gp met $t0 
 
 
 lw $ra, -4($fp)       # Laad $ra in $fp - 4
 move $sp, $fp         # Stack pointer naar oude frame pointer
 lw $fp, ($sp)         # Nieuwe stack pointer
 jr $ra                # Ga naar $ra
 
 
# Geef aan dat coordinaat buiten bereik is
ongeldig:
la $a0, Ongeldig
li $v0, 4
syscall

exit:
 #Beëindig het programma
 li $v0, 10
 syscall
 
 





