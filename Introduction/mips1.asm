
.data
spatie_rijen: .asciiz "\n"     #Spaties voor de rijen onder elkaar af te drukken
spatie_cijfers: .asciiz " "    #Spaties tussen de cijfers

.text 
main: 
    li $v0, 5    #Vraag een integer op van de user (aantal rijen)
    syscall   
    move $t0, $v0    #Verplaats opgevraagde waarde naar register $t1  
    
    li $t1, 1    #Laad het beginnummer 1  naar register $t1
    li $t2, 1    #Laad 1 naar register $t2
    li $t3, 1    #Laad 1 naar register $t3
    
resetreg:  
    li $t2, 1    #Laad 1 naar register $t2 => reset naar 1
    
row: 
    la $a0, 0($t2)    #Laad address van register $t2 naar $a0
    li $v0, 1        #Print integer
    syscall
    addi $t2, $t2, 1      #Vermeerder waarde in register $t2 met 1
    la $a0, spatie_cijfers     #Laad address van spatie_cijfers naar reg $a0   
    li $v0, 4                 #Print string (spatie)
    syscall
    bgt $t2, $t3, Jumprow       #Als de waarde van $t2 groter is dan $t3 => Jumprow (rij lager)
    j row                       #Ga verder naar row en voeg een tweede getal toe in de rij
    
Jumprow: 
        beq $t3,$t0, Exit          # Als de waarde van $t3 gelijk is aan die van $t0 => exit status
        addi $t3, $t3, 1            # Vermeerder de waarde van $t3 met 1
        la $a0, spatie_rijen        #Laad het address van spatie_rijen naar reg $a0
        li $v0, 4                   #Print string
        syscall
        j resetreg                   #Jump naar resetreg 
     
Exit:
    li $v0, 10          #Beëindig programma
    syscall    
    