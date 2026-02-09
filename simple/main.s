        .setcpu "65C02"

; ACIA registers
; 68B50 

ACIA_BASE    = $7F00
ACIA_CTRL_STATUS = ACIA_BASE            ; CTRL:RWB=0 STATUS:RWB=1
ACIA_TX_RX       = ACIA_BASE + 1        ; TRANSMIT:RWB=0 RECEIVE:RWB=1

ACIA_CTRL_CR0     = %00000001           ; Counter divide bits
ACIA_CTRL_CR1     = %00000010
ACIA_CTRL_WS1     = %00000100           ; Word Select bits
ACIA_CTRL_WS2     = %00001000           ; 
ACIA_CTRL_WS3     = %00010000           ;
ACIA_CTRL_TXCTRL1 = %00100000           ; Transmit Xontrol
ACIA_CTRL_TXCTRL2 = %01000000
ACIA_CTRL_RXINTEN = %10000000           ; Revieve Interrupt Enable

ACIA_RESET        = %00000011
ACIA_8N1          = %00010100

ACIA_STATUS_RDRF  = %00000001           ; Receive Data Register Full
ACIA_STATUS_TDRE  = %00000010           ; Transmit Data Register Empty
ACIA_STATUS_DCD   = %00000100           ; Data Carrier Detect
ACIA_STATUS_CTS   = %00001000           ; Clear to Send
ACIA_STATUS_FE    = %00010000           ; Framing Error
ACIA_STATUS_OVRN  = %00100000           ; Overrun Error
ACIA_STATUS_PE    = %01000000           ; Parity Error
ACIA_STATUS_IRQ   = %10000000           ; State of IRQ Output of ACIA

        .segment "VECTORS"

        .word    DUMMY_vec
        .word    RES_vec
        .word    DUMMY_vec

        .code

DUMMY_vec:
        RTI

;======= START =========================================
RES_vec:
main:
        CLD             ; Clear Decimal
        LDX #$FF        ; Reset stack
        TXS

        jsr acia_init

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
        lda ACIA_CTRL_STATUS 
        and #ACIA_STATUS_RDRF   ; Receiver Data Register Full
        beq rx_loop             ; keep looping till receive
        ; got something
        lda ACIA_TX_RX          ; get data

        jsr send_char           ; write it back out
        jmp rx_loop

;======= END ===========================================

;-------------------------------------------------------
; Initialise ACIA to 8N1 9600 baud
acia_init:
        pha
        ; 68B50 can do a SW reset
        lda #ACIA_RESET
        sta ACIA_CTRL_STATUS ; reset
        nop
        nop
        nop
        nop
        lda #0
        sta ACIA_CTRL_STATUS ; end reset sequence

        ; with external baud rate generator : RxCLK and TxCLK are 153600, giving DIV16=9600
        lda #(ACIA_8N1 | ACIA_CTRL_CR0)     ; Also RTS low, Tx Interrupt disabled
        sta ACIA_CTRL_STATUS
        pla
        rts
;-------------------------------------------------------

;-------------------------------------------------------
; subroutine to send 1 char - in Accumulator
send_char:
        pha                     ; Save accum
wait_tdre1:
        ; wait for TDRE to be high
        lda ACIA_CTRL_STATUS
        and #ACIA_STATUS_TDRE
        beq wait_tdre1
        
        pla                     ; Get acc back
        sta ACIA_TX_RX          ; and write out
        rts
;-------------------------------------------------------


msg_hello: .byte "Hello World",$0D,$0A,$00



