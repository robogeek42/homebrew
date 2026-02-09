        .setcpu "65C02"

        .segment "VECTORS"

        .word    DUMMY_vec
        .word    RES_vec
        .word    DUMMY_vec

        .code

DUMMY_vec:
        RTI

RES_vec:

; This test will show validity of memory read/write 
; just by examining data values on a scope
; Good: you should see repeating reads/writes from $4000, $4001
; Bad: repeat read from $4002
main:
        CLD             ; Clear Decimal
        LDX #$FF        ; Reset stack
        TXS
        
        ; Write 2 different values to two memory locations
        LDA #$AB
        STA $4000
        NOP
        LDA #$C5
        STA $4001
        NOP

        ; Load the value at the 1st address and check it
        LDA $4000
        SEC
        SBC #$AB 
        BNE bad         ; we end here if it fails

        ; Similar for 2nd vaule
        LDA $4001
        SEC
        SBC #$C5
        BNE bad
        NOP
        JMP main        ; If all is good we start again

bad:    ; bad loop just references a different memory location
        LDA $4002
        JMP bad
        

