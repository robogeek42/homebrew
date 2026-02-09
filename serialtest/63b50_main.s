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

RES_vec:
main:
        CLD             ; Clear Decimal
        LDX #$FF        ; Reset stack
        TXS

; acia_init   
        lda #ACIA_RESET
        sta ACIA_CTRL_STATUS ; reset
        nop
        nop
        nop
        nop
        lda #0
        sta ACIA_CTRL_STATUS 

        ; probably should also set RX Interrupt Enable to cause IRQ to get characters?
        ; XXX BAUD rate is CLK/64 (CR0=0, CR1=1) CLK=1.8432MHz/2 BAUD=14,400
        ; XXX BAUD rate is CLK/64 (CR0=0, CR1=1) CLK=1.8432MHz BAUD=28,800  The Prolific Driver can't do this!
        ; BAUD rate is CLK/16 (CR0=1, CR1=0) CLK=1.8432MHz BAUD=115,200 ... really fast

        ; with external baud rate generator : RxCLK and TxCLK are 153600, giving DIV16=9600

        lda #(ACIA_8N1 | ACIA_CTRL_CR0)     ; Also RTS low, Tx Interrupt disabled
        sta ACIA_CTRL_STATUS


; receive character in a loop and write back to acia
rx_loop:
        lda ACIA_CTRL_STATUS 
        and #ACIA_STATUS_RDRF   ; Receiver Data Register Full
        beq rx_loop             ; keep looping till receive

        ; got something

        lda ACIA_TX_RX          ; get data
        pha                     ; save it on the stack

        ; Transmit Character
        
wait_tdre1:
        ; wait for TDRE to be high
        lda ACIA_CTRL_STATUS
        and #ACIA_STATUS_TDRE
        beq wait_tdre1

        ;pla
        ;inc                     ; Add 1 to char

        lda #$2A       ; *
        sta ACIA_TX_RX          ; write character in Accum
        
        ; could wait here again, but we will always wait before we send a character anyway

wait_tdre2:
        ; wait for TDRE to be high
        lda ACIA_CTRL_STATUS
        and #ACIA_STATUS_TDRE
        beq wait_tdre2

        pla
        sta ACIA_TX_RX          ; write received character straight back out
        
        jmp rx_loop
