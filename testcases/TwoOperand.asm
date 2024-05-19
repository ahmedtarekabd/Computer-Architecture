# all numbers in hex format
# we always start by reset signal
# this is a commented line
# You should ignore empty lines

# ---------- Don't forget to Reset before you start anything ---------- #

.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
FF

.ORG FF

NOP
IN R1             #add 5 in R1
IN R2             #add 19 in R2
IN R3             #FFFFFFFF
IN R4             #FFFFF320
NOP
NOP
MOV R5, R3         #R5 = FFFFFFFF , flags no change
ADD R4,R1,R4      #R4= FFFFF325 , C-->0, N-->1, Z-->0
NOP
NOP
SUB R6,R5,R4      #R6= 00000CDA , C-->0, N-->0,Z-->0 here carry is implemented as borrow, you can implement it as not borrow
AND R4,R7,R4      #R4= 00000000 , C-->no change, N-->0, Z-->1
SWAP R2, R4  
ADD R2,R1,R2      #R2= 5 (C,N,Z= 0)
ADD R6,R4,R2      #R6=0001001D
SUBI R6, R6, 3    #R6=0001001A
OR R3, R2, R6     #R3=0001001F 
XOR R1, R3, R3    #R1=00000000 (Z = 1)
CMP R1, R3        #(C = 1, N = 1, Z = 0)
ADD R6, R5, R5    # Overflow exception
