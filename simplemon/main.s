.setcpu "6502"

.include "macros.inc65"
.include "zeropage.inc65"
.include "acia.inc65"
.include "io.inc65"

.segment "VECTORS"

            .word    main
            .word    RES_vec
            .word    main

.code

RES_vec:
main:   
            CLD         ; Clear decimal bit
            LDX #$FF    ; reset Stack
            TXS

            ; Intialise serial
            JSR acia_init

            ld16 R0, msg_hello
            JSR acia_puts

            jmp main

msg_hello:      .byte "Hello World", $0D, $0A
