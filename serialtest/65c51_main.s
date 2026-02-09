        .setcpu "65C02"

; ACIA registers

ACIA_BASE    = $7F00
ACIA_DATA    = ACIA_BASE
ACIA_STATUS  = ACIA_BASE + 1
ACIA_COMMAND = ACIA_BASE + 2
ACIA_CONTROL = ACIA_BASE + 3

        .segment "VECTORS"

        .word    DUMMY_vec
        .word    RES_vec
        .word    DUMMY_vec

        .code

DUMMY_vec:
        RTI

RES_vec:
main:
        CLD             ; Clear Decimal
        LDX #$FF        ; Reset stack
        TXS

; acia_init   
        lda #0
        sta ACIA_STATUS ; reset

        ;lda #%00011110  ; baud 9600, use crystal for clk
        lda #%00011111  ; baud 19200, use crystal for clk
        ;lda #%00000000  ; baud ext_clk/16 = 115200 
        sta ACIA_CONTROL
        
        lda #%00001011  ; TX_INT_DISABLE_RTS_LOW
                        ; RX_INT_DISABLE
                        ; DTR_LOW 
        ;lda #%00000000   ; ? RTR is Hi - this may not work
        sta ACIA_COMMAND
        


; receive character in a loop and write back to acia
rx_loop:
;        lda ACIA_STATUS 
;        and #$08        ; bit 3 Receiver Data Register Full
;        beq rx_loop     ; keep looping till receive

                        ; got something
;        lda ACIA_DATA   ; get data
        lda #'.'
        sta ACIA_DATA   ; write character

        ;ldx #206           ; 206 * 5us = 1030us 
        ldx #103
tx_delay_loop:
        dex                ; 2 instr cycles  = 2us
        bne tx_delay_loop  ; 3 instr cycles  = 5us

        jmp rx_loop



