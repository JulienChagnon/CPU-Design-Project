ORG 0x000

ldi R5, 0x43
ldi R5, 6(R5)
ld R4, 0x89
ldi R4, 4(R4)
ld R0, -8(R4)
ldi R2, 4
ldi R5, 0x87
brmi R5, 3
ldi R5, 5(R5)
ld R1, -3(R5)
nop
brpl R1, 2
ldi R3, 7(R5)
ldi R7, -4(R3)
add R7, R5, R2
addi R1, R1, 3
neg R1, R1
not R1, R1
andi R1, R1, 0xF
ror R4, R0, R2
ori R1, R4, 5
shra R4, R1, R2
shr R5, R5, R2
st 0xA3, R5
rol R5, R0, R2
or R7, R2, R0
and R4, R5, R0
st 0x89(R4), R7
sub R0, R5, R7
shl R4, R5, R2
ldi R7, 7
ldi R3, 0x19
mul R3, R7
mfhi R1
mflo R6
div R3, R7
ldi R8, 2(R7)
ldi R9, -4(R3)
ldi R10, 3(R6)
ldi R11, 5(R1)
jal R10
in R6
st 0x77, R6
ldi R3, 0x2E
ldi R5, 1
ldi R2, 40
loop: out R6
ldi R2, -1(R2)
brzr R2, 8
ld R7, 0x88
loop2: ldi R7, -1(R7)
nop
brnz R7, -3
shr R6, R6, R5
brnz R6, -9
ld R6, 0x77
jr R3
done: ldi R6, 0x63
out R6
halt

ORG 0x0B2

add R14, R8, R10
sub R13, R9, R11
sub R14, R14, R13
jr R12
