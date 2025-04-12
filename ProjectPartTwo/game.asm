 .globl main

.data
mazeFilename:    .asciiz "test_maze.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "\n You have won the game!"

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)

.text

main:

  jal create_background      # Kleur de achtergrond
  
   main_loop:
  
    li $v0, 12               # Vraag een karakter op
    syscall
    
    move $t0, $v0            # Plaats het karakter in register $t0
    
    jal Input_move           # Kijk na of de input geldig is 
                             # Verplaats indien nodig speler
                             
    move $t0, $a0            # Tijdelijk opslaan $a0 (rijnummer)
    li $v0, 32               # Sleep
    la $a0, 60               # Sleep 60ms seconden
    syscall
     
    move $a0, $t0            # Plaats originele waarde $a0 terug
   
    j main_loop              # Loop opnieuw
    
        
Input_move:
    # Stack frame
    sw $fp, 0($sp)          # Sla oude $fp op
    move $fp, $sp           # Verplaats frame pointer naar top v/d stack
    subu $sp, $sp, 12       # Alloceer plaats op de stack
    sw $ra, -4($fp)         # Plaats $ra in frame

    # Ga na of de input geldig is
    beq $t0,'z',up_z
    beq $t0,'s',down_s
    beq $t0,'q',left_q
    beq $t0,'d',right_d
    beq $t0, 'x', exit
    
    # Geen geldige input? => verlaat procedure
    j leave_procedure
   
    # Karakter is z
    up_z:                          # Speler naar boven
     subi $a2, $a0, 1              # Plaats rijnummer - 1 in $a2
     move $a3, $a1                 # Plaats huidige kolomnummer in $a3
     jal Player_movement           # Beweeg de speler => procedure Player_movement
     j return_new_coordinate       # Verlaat procedure Input_move bij terugkeer uit Player_movement
  
    # Karakter is s
    down_s:                        # Speler naar beneden
     addi $a2, $a0, 1              # Plaats rijnummer + 1 in $a2
     move $a3, $a1                 # Plaats huidige kolomnummer in $a3 
     jal Player_movement           # Beweeg de speler => procedure Player_movement
     j return_new_coordinate       # Verlaat procedure Input_move bij terugkeer uit Player_movement
 
    # Karakter is q
    left_q:                        # Speler naar links
     subi $a3, $a1, 1              # Plaats kolomnummer - 1 in $a3
     move $a2, $a0                 # Plaats huidige rijnummer in $a2
     jal Player_movement           # Beweeg de speler => procedure Player_movement
     j return_new_coordinate       # Verlaat procedure Input_move bij terugkeer uit Player_movement
  
    # Karakter is d
    right_d:                       # Speler naar rechts
     addi $a3, $a1, 1              # Plaats kolomnummer + 1 in $a3
     move $a2, $a0                 # Plaats huidige rijnummer in $a2
     jal Player_movement           # Beweeg de speler => procedure Player_movement
     j return_new_coordinate       # Velaat procedure Input_move bij terugkeer uit Player_movement
     
     
    return_new_coordinate:
     move $a0, $v0                  # Plaats nieuwe rijnummer (return) in $a0
     move $a1, $v1                  # Plaats nieuwe kolomnummer (return) in $a1
    
    leave_procedure:               # Ga uit de procedure met behulp van $ra
     lw $ra, -4($fp)               # Laad $ra vanuit stack frame
     move $sp, $fp                 # Stack pointer naar oude frame pointer (Clear stack frame)
     lw $fp, 0($sp)                # Herstel oude frame pointer
     jr $ra                        # Ga naar $ra
   
   
Player_movement:
    # Stack frame
    subu $sp, $sp, 16                    # Alloceer 16 bytes op de stack
    sw $a0, 16($sp)                      # Sla argument (huidige rij) op boven stack frame
    sw $a1, 12($sp)                      # Sla argument (huidige kolom) op boven stack frame
    sw $a2, 8($sp)                       # Sla berekende rij op boven stack frame
    sw $a3, 4($sp)                       # Sla berekende kolom op boven stack frame
    sw $fp, 0($sp)                       # Plaats oude frame pointer op
    move $fp, $sp                        # Verplaats frame pointer naar top v/d stack
    subu $sp, $sp, 8                     # Alloceer 8 bytes op de stack (voor frame)
    sw $ra, -4($fp)                      # Plaats $ra op in frame
    
    lw $s1, 8($fp)                       # Plaats berekende rij in $s1
    lw $s2, 4($fp)                       # Plaats berekende kolom in $s2
    lw $v0, 16($fp)                      # Plaats huidige kolomnummer in return $v0
    lw $v1, 12($fp)                      # Plaats huidige kolomnummer in return $v0
    
    lw $t0, amountOfRows                 # Laad aantal rijen in $t0
    bge $s1, $t0, leave_frame            # Buiten bereik? => verlaat Player_movement
    lw $t0, amountOfColumns              # Laad aantal kolommen in $t0
    bge $s2, $t0, leave_frame            # Buiten bereik? => verlaat Player_movement
    blt $s2, 0, leave_frame              # Buiten bereik (kolommen) => verlaat Player_movement
    blt $s1, 0, leave_frame              # Buiten bereik (rijen) => verlaat Player_movement
  
    jal coordinaat                       # Bereken coordinaat v/d pixel
    la $t0, 0($v0)                       # Laad adres return waarde $v0 naar $t0
    lw $t2, 0($t0)                       # Plaats pixel adres in $t2
    lw $t1, wallColor                    # Plaats kleur muur in $t1
    
    lw $v0, 16($fp)                      # Plaats rijnummer in $v0
    lw $v1, 12($fp)                      # Plaats kolomnummer in $v1
    
    beq $t2, $t1, leave_frame            # Indien muur => verlaat Player_movement
    lw $t3, 0($t0)                       # Adres nieuwe positie in $t3
    
    # Verzet speler 
    lw $t1, playerColor                  # Laad de kleur van de speler in $t1       
    sw $t1, 0($t0)                       # Verzet speler naar nieuwe positie
  
    lw $s1, 16($fp)                      # Plaats vorige rij in $s1
    lw $s2, 12($fp)                      # Plaats vorige kolom in $s2
  
    # Vorige pixel zwart kleuren
    jal coordinaat
    la $t0, 0($v0)             
    lw $t1, passageColor                 # Laad kleur doorgang naar $t1
    sw $t1, 0($t0)                       # Plaats kleur doorgang in pixel
  
    # Checken op kleur uitgang
    lw $t0, exitColor                    # Plaats kleur uitgang in $t0
    beq $t3, $t0, winner_message         # Uitgang bereikt? => winner_message
    
    lw $v0, 8($fp)                       # Return nieuwe rijnummer (in $v0)
    lw $v1, 4($fp)                       # Return nieuwe kolomnummer (in $v1)
    
      leave_frame:
       lw $ra, -4($fp)                   # Laad $ra vanuit stack frame
       move $sp, $fp                     # Clear stack frame
       lw $fp, 0($sp)                    # Herstel oude frame pointer
       jr $ra                            # Ga naar $ra
   
create_background:
    # Stack frame
    sw $fp, 0($sp)                   # Push oude frame pointer op stack
    move $fp, $sp                    # Nieuwe frame pointer naar top v/d stack
    subu $sp, $sp, 8                 # Alloceer plaats op de stack
    sw $ra, -4($fp)                  # Sla $ra op in -4($fp)
    
    Bestand_inlezen: 
    li $v0, 13                       # Open het bestand om te lezen
    la $a0, mazeFilename             # Output bestand
    li $a1, 0                        # Zorgt ervoor dat de schrijfmodus uit staat
    li $a2, 0              
    syscall

    move $s0, $v0                    # Sla de file descriptor op in $s0
  
    li $v0, 14                       # Lees van het bestand naar buffer
    move $a0, $s0                    # Sla file descriptor op in $a0
    la $a1, buffer                   # Laad adres buffer naar $a1
    li $a2, 4096                     # Laad grootte v/d buffer naar $a2
    syscall
  
    li $v0, 16                       # Sluit het bestand
    move $a0, $s0                    # Plaats file descriptor in $a0
    syscall

    la $s0, buffer                   # Address van buffer in $s0
    li $s1, 0                        # Sla rijnummer op in $s1
    li $s2, 0                        # Sla kolomnummer op $s2 
  
    Fill_maze:
    lb $t1, 0($s0)                   # Laad address huidige karakter naar $t1
    lw $t0, amountOfRows             # Laad aantal rijen in register $t0
    bge $s1, $t0, Exit_procedure     # Aantal rijen >= 16 => ga uit de procedure
    
    # Spring naar gewenste label op basis van karakter
    beq $t1, 'w', Kleur_muur   
    beq $t1, 'p', Kleur_doorgang 
    beq $t1, 's', Kleur_speler    
    beq $t1, 'u', Kleur_uitgang  
    beq $t1, '\r', Add_buffer  
    beq $t1, '\n', New_line
    
    j Exit_procedure           # Verlaat procedure indien ongeldig karakter
 
    Kleur_muur:
    lw $t0, wallColor          # Laad kleur blauw naar $t0
    j Kleur_pixel
  
    Kleur_doorgang:
    lw $t0, passageColor       # Laad kleur zwart naar $t0
    j Kleur_pixel              # Kleur pixel zwart => label Kleur_pixel
 
    Kleur_speler:
    lw $t0, playerColor        # Laad kleur geel naar $t0
    move $a0, $s1              # Sla startpositie (rij) speler op in $a0
    move $a1, $s2              # Sla startpositie (kolom) speler op in $a1
    j Kleur_pixel              # Kleur pixel geel => label Kleur_pixel

    Kleur_uitgang:
    lw $t0, exitColor          # Laad kleur groen naar $t0
    j Kleur_pixel              # Kleur pixel groen => label Kleur_pixel
  
    
    New_line:                  # Spring naar volgende rij (indien '\n' karakter)
    addi $s1, $s1, 1           # Vermeerder rijnummer met 1
    li $s2, 0                  # Zet kolmnummer terug op 0
    addi $s0, $s0, 1           # Vermeerder het adres van de buffer met 1 byte
    j Fill_maze                # Ga naar label Fill_maze
    
    Add_buffer:                # Als Carriage Return(Windows) => buffer adres+1
    addi $s0, $s0, 1           # Vermeerder adres buffer in $s0 met 1
    j Fill_maze                # Ga naar label Fill_maze

    Kleur_pixel:
    jal coordinaat             # Functie coordinaat
    la $t1, ($v0)              # Laad address pixel naar $t1
    sw $t0, 0($t1)             # laad kleur op address pixel
    addi $s0, $s0, 1           # Vermeerder adres van huidige buffer met 1
    addi $s2, $s2, 1           # Vermeerder kolomnummer met 1
    j Fill_maze
    
    Exit_procedure:
    lw $ra, -4($fp)            # Laad $ra vanuit stack frame
    move $sp, $fp              # Stack pointer naar oude frame pointer
    lw $fp, 0($sp)             # Herstel oude frame pointer
    jr $ra                     # Ga naar $ra
    
    
coordinaat:
   # Stack frame
   sw $fp, 0($sp)              # Vorige frame pointer naar 0($sp)
   move $fp, $sp               # Frame pointer naar top van stack
   subu $sp, $sp, 12
   sw $ra, -4($fp)             # Plaats $ra in frame
   sw $t0, -8($fp)             # Plaatst de kleur in $t0 in stack frame
  
   lw $t2, amountOfColumns     # Laad het aantal kolommen naar $t2
   mul $t0, $s1, $t2           # Vermenigvuldig rij met aantal kolommen (bepaalt rij)
   add $t0, $t0, $s2           # Tel kolomnummer op bij rij (bepaalt kolom in rij)
   sll $t0, $t0, 2             # Vermenigvuldig geheel met 4 (elke pixel 4 bytes)
   addu $v0, $gp, $t0          # Vermeerder de $gp met $t0 en zet adres in $v0 (return)

   lw $ra, -4($fp)             # Laad $ra in $fp - 4
   lw $t0, -8($fp)             # Laad de $t0 
   move $sp, $fp               # Stack pointer naar oude frame pointer
   lw $fp, 0($sp)              # Nieuwe stack pointer
   jr $ra                      # Ga naar $ra


winner_message:
   # Print victory Message
   la $a0, victoryMessage
   li $v0, 4
   syscall 
  
exit:
   # syscall to end the program
   li $v0, 10    
   syscall
