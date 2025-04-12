.data

priemgetal: .asciiz "--Prime--"     #Terug te geven string als getal priem is
geen_priem: .asciiz "--No prime--"    #Terug te geven string als getal niet priem is

.text
main:
     li $v0, 5          #Vraagt integer input van de gebruiker op
     syscall
     
     move $t0, $v0       #Verplaatst de opgevraagde waarde naar register $t0
     li $t1, 1         #Laad de waarde 1 naar register $t1
     li $t3, 1            #Laad de waarde 1 naar register $t3 (exception value)
     beq $t0, $t3, nopriem  #Als de input gelijk is aan 1 => jump naar nopriem (1 is geen priemgetal)
     
     
loop:
    addi $t1, $t1, 1       #Voeg 1 toe bij de register $t1
    beq $t1, $t0, priem    #Als $t1 gelijk is aan de opgevraagde waarde => priemgetal ($t0 is "grens" van deling)
    div $t2, $t0, $t1      #Deel de opgevraagde waarde door de waarde in $t1
    mfhi $t4               #De rest van de deling wordt opgeslagen in register $t4
    beq $t4, $zero, nopriem    #Als de rest 0 is => geen priemgetal (jump naar nopriem)
    j loop                    #Jump naar loop
      
nopriem:
    la $a0, geen_priem       #Laad het address van geen_priem naar $a0
    li $v0, 4                 #Output --No prime--
    syscall 
    
Exit_nopriem:    
    li $v0, 10               #Gaat uit het programma zodat priem niet uitgevoerd wordt
    syscall
priem:
    la $a0, priemgetal        #Laad het address van priemgetal naar $a0
    li $v0, 4                 #Ouput --Prime--
    syscall
Exit_priem: 
     li $v0, 10              #Beëindig het programma
     syscall
     
    