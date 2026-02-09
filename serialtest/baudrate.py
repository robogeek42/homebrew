#!/bin/python3

CLK = 1843200

PROLIFIC_BAUD_RATES = (75,110,134,150,300,600,1200,1800,2400,4800,7200,9600,14400,19200,38400,57600,115200,128000)

for divider in 1,16,64:
    for ctr in 1,2,3,4,6,8,12:
        BAUD = int( CLK/(ctr*divider) )
        if BAUD in PROLIFIC_BAUD_RATES:
            AST = "*"
        else:
            AST = ""
        print(f'Chip Div: {divider}  Counter: {ctr} \t--> {BAUD}\t{AST}')
