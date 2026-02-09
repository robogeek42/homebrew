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
        jsr tx_delay

        lda #%00001011  ; TX_INT_DISABLE_RTS_LOW
                        ; RX_INT_DISABLE
                        ; DTR_LOW 
        sta ACIA_COMMAND
        nop

        lda #%00011110  ; baud 9600, use crystal for clk
        sta ACIA_CONTROL
        nop


; Write Hello World message

        ldx #0
send_loop:
        lda msg_hello,x
        beq done        ; End of message
        jsr send_char   ; send character over serial
        inx
        bne send_loop   ; loop for max 256 times
done:

        
; receive character in a loop and write back to acia
rx_loop:
        lda ACIA_STATUS 
        and #$08        ; bit 3 Receiver Data Register Full
        beq rx_loop     ; keep looping till receive

                        ; got something
        lda ACIA_DATA   ; get data
        jsr send_char
        ;nop
        jmp rx_loop


; subroutine to send 1 char
send_char:
        pha
tx_wait:
        nop
        nop
        nop
        nop
        nop
        nop
        lda ACIA_STATUS ; Wait for Transmit Data Register Empty
        and #$10        ; bit 4 
        beq tx_wait     ; will never get 0 status because of HW bug

        jsr tx_delay    ; delay as wait won't work

        pla
        ina
        sta ACIA_DATA   ; write character

        rts

; Custom Delay loop
; delay for log enough to send 1 char (10bits) at 9600 baud
; Clk is 1MHz (1 clock cycle = 1us)
; so delay needs to be 10*1/9600 seconds = 1042us
tx_delay:
        phx
        ldx #206           ; 206 * 5us = 1030us (Plus some(20) for jsr(6), phx(3), ldx(2), plx(3) and rts(6) )
tx_delay_loop:
        dex                ; 2 instr cycles  = 2us
        bne tx_delay_loop  ; 3 instr cycles  = 5us
        plx
        rts

msg_hello: .byte "Hello World",$0D,$0A,$00



