{{┌─────────────────────────────────────────────────────────┐   │ PASM 13a - Using a message table - Stand-alone routine  │  │ Author: Chris Gadd                                      │   │ Copyright (c) 2012 Chris Gadd                           │   │ See end of file for terms of use.                       │   └─────────────────────────────────────────────────────────┘   A lookup table is fine when all of the elements have the same length, but it gets a bit more complicated with elements of   varying lengths as you can't simply add a single offset to reach the right start address.  One method looked at in this routine uses the lookup table to store the start address of each message   That message address is retrieved by adding an index representing the message number to the base address of the lookup table   Run on its own, any program has a base address of $10, but varies if it is included as an object in another program.       mov     Table_address,par                     ' par contains the address of the Message_table    add     Table_address,index                   ' index is the message number (starting from 0)    rdbyte  Message_address,Table_address         ' Retrieve the message address from the message table    add     Message_address,#$10                  ' Add an offset to get past the reserved bytes  :Loop    rdbyte  Message_character,Message_address     ' Retrieve the first character of the message, increment Message_address to read the rest    call    #Display_character    add     Message_address,#1    jmp     #:Loop}}CON_clkmode  = xtal1 + pll16x                                              _xinfreq  = 5_000_000Tx_pin    = 30Baud      = 9600PUB Main  cognew(@Message_table_example, @Message_table)DAT                     orgMessage_table           byte      @Message_1                                    ' Address of Message_1 in hub memory                        byte      @Message_2                                    ' Address of Message_2                        byte      @Message_3                                    ' Address of Message_3                        byte      @Message_4                                    ' Address of Message_4Message_1               byte      "This is message 1",$0D,0Message_2               byte      "This is message two",$0D,0Message_3               byte      "This is message three",$0D,0Message_4               byte      "This is message four",$0D,0                                                                     DAT                     orgMessage_table_example                                                                   or        dira,Tx_mask                        or        outa,Tx_maskMain_Loop                        mov       Loop_counter,#0:Loop                        mov       Index,Loop_counter                                          call      #Read_Message                                 ' Uses index to read the message address, and message address to read the message                        add       Loop_counter,#1                        cmp       Loop_counter,#3             wz          if_ne         jmp       #:Loop                        jmp       #Main_Loop'----------------------------------------------------------------------------------------------------------------------Read_Message'Find_index                        mov       Address,par                                   ' Move the base address of the message table into address                        add       Address,Index                                 ' Add the index to the message table address                        rdbyte    Address,Address                               ' Read the message address from the table address                        add       Address,#$10                                  ' Add an offset to get past the sixteen reserved bytes (only works in a stand-alone program):Loop                        rdbyte    UART_byte,Address           wz                ' Read a character from the message address          if_z          jmp       Read_Message_ret                              ' Jump if the character is 0 (null termination) ("#" can be omitted for this jump - jumping to                         call      #UART_Transmit                                ' Transmit the character                             an address contained in another location)                        add       Address,#1                                    ' Add one to the address                        jmp       #:Loop                                        ' Loop characters transmittedRead_Message_ret        ret'----------------------------------------------------------------------------------------------------------------------UART_Transmit                        or        UART_byte,#$100                               ' Add a stop bit                        shl       UART_byte,#1                                  ' Add a start bit                        mov       Bit_counter,#10                               ' Initialize to send 1 start, 8 data, and 1 stop                        mov       cnt,Bit_delay                                 ' Prepare to wait one bit width                        add       cnt,cnt                                       ' Add the current count:Loop                        shr       UART_byte,#1                wc                ' Shift LSB out of Tx_Byte into C                        muxc      outa,Tx_mask                                  ' Set / clear the Tx_pin depending on status of C                        waitcnt   cnt,Bit_delay                        djnz      Bit_counter,#:Loop                            ' Loop if ten bits not sentUART_Transmit_ret       ret'----------------------------------------------------------------------------------------------------------------------Tx_mask                 long      1 << Tx_pinBit_delay               long      _xinfreq * 16 / BaudMessage_address         res       1UART_byte               res       1Bit_counter             res       1Index                   res       1Address                 res       1Loop_counter            res       1                        fitDAT                     {{┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐│                                                   TERMS OF USE: MIT License                                                  │                                                            ├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ │files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ││modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software││is furnished to do so, subject to the following conditions:                                                                   ││                                                                                                                              ││The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.││                                                                                                                              ││THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ││WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ││COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ││ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘}}                                                                      