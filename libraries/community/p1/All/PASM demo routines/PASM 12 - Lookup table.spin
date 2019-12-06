{{┌──────────────────────────────────────────┐        │ PASM 12 - Using a lookup table           │        │ Author: Chris Gadd                       │        │ Copyright (c) 2012 Chris Gadd            │        │ See end of file for terms of use.        │        └──────────────────────────────────────────┘        Lookup tables are useful for retrieving one value (element) based on a second value (index)  In this example, the squares of the first ten numbers are retrieved from a lookup table and displayed on the serial terminal                                                                                                                  gets passed to Example as par                                                                                                                    First, the address of the lookup table must be passed to the routine, easily done through par: cognew(@Example, @Lookup_table)  Next, an index is added to the address of the lookup table:  add     Address,Index  And the square is read from the table:                       rdbyte  UART_byte,Address  And the square is transmitted:                               call    #UART_Transmit  There is an added complication in that each element is three bytes long, meaning that the index needs to be multiplied by three.  To read all three characters, set a counter to loop three times, adding one to the indexed message address each time through the loop.   }}CON_clkmode  = xtal1 + pll16x                                                 _xinfreq  = 5_000_000Tx_pin    = 30Baud      = 9_600PUB Main  cognew(@Lookup_table_example, @Lookup_table)DAT                     orgLookup_table            byte      "001","004","009","016","025","036","049","064","081","100"  ' Note that all elements must be of equal length        DAT                     orgLookup_table_example                                                                    or        dira,Tx_mask                        or        outa,Tx_maskMain_Loop                        mov       Index,#0Squares_Loop                        call      #Read_Table                        mov       UART_byte,#$0D                        call      #UART_Transmit                                                add       Index,#1                        cmp       Index,#10                   wz                          if_ne         jmp       #Squares_Loop                                 ' Keep looping until all squares displayed                        mov       UART_byte,#$01                        call      #UART_Transmit                        mov       Delay_counter,Delay_1sec                        djnz      Delay_counter,#$                        jmp       #Main_Loop                        '----------------------------------------------------------------------------------------------------------------------Read_Table                        mov       Address,Index                                                         shl       Address,#1                                    ' Shift left once to multiply by 2                        add       Address,Index                                 ' and add once for multiply by 3                        add       Address,par                                   ' Add the address of the lookup table                        mov       Loop_counter,#3                               ' Initialize loop counter to display 3 characters:Loop                        rdbyte    UART_byte,Address                             ' Read a character from the indexed address                        call      #UART_Transmit                                ' Transmit the character                        add       Address,#1                                    ' Add one to the address                        djnz      Loop_counter,#:Loop                           ' Loop until all three characters transmittedRead_Table_ret          ret'----------------------------------------------------------------------------------------------------------------------UART_Transmit                                                                     or        UART_byte,#$100                               ' Add a stop bit                        shl       UART_byte,#1                                  ' Add a start bit                        mov       Bit_counter,#10                               ' Prepare to send 1 start, 8 data, and 1 stop                        mov       cnt,Bit_delay                                 ' Initialize the wait time                        add       cnt,cnt                                       '  Add the current time as an offset:Loop                        shr       UART_byte,#1                wc                ' Shift lsb out of Data into C                        muxc      outa,Tx_mask                                  ' Set / clear the Tx_pin depending on C                        waitcnt   cnt,Bit_delay                                 ' Wait one bit width                        djnz      Bit_counter,#:Loop                            ' Loop until ten bits sentUART_Transmit_ret       ret'----------------------------------------------------------------------------------------------------------------------Tx_mask                 long      1 << Tx_pinBit_delay               long      _xinfreq * 16 / BaudDelay_1sec              long      20_000_000Delay_counter           res       1UART_byte               res       1Bit_counter             res       1Index                   res       1Address                 res       1Loop_counter            res       1                        fitDAT                     {{┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐│                                                   TERMS OF USE: MIT License                                                  │                                                            ├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ │files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ││modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software││is furnished to do so, subject to the following conditions:                                                                   ││                                                                                                                              ││The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.││                                                                                                                              ││THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ││WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ││COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ││ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘}}                                                                      