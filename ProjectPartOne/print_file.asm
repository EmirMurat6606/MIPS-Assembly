.data
bestand:    .asciiz  "test_file_1.txt"     # Naam v. bestand
buffer:     .space 2048

.text
main: 
# Open om te lezen
li $v0, 13           # Open het bestand
la $a0, bestand      # Output bestand
li $a1, 0            # Zorgt ervoor dat de schrijfmodus uit staat
li $a2, 0            # Mode staat uit
syscall

move $s0, $v0        # Sla de file descriptor op in $s0

# Lees van het bestand naar buffer
li $v0, 14
move $a0, $s0        # Sla file descriptor op in $a0
la $a1, buffer       # Laad address buffer naar $a1
li $a2, 2048         # Laad grootte buffer naar $a2
syscall

# Print inhoud van het bestand
li $v0, 4
la $a0, buffer       # Laad het adres van het buffer in $a0
syscall

# Sluit het bestand
li $v0, 16
move $a0, $s0
syscall

Exit:
# Stop programma
li $v0, 10
syscall
