{{

┌──────────────────────────────────────────┐
│ morse_code v1.2                          │
│ Author: Thomas Earl McInnes              │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

a *-
b -***
c -*-*
d -**
e *
f **-*
g --*

}}

VAR

  Long tpin, freqpin

OBJ

  s     :       "Synth"

PUB start_up(trans_pin)

  tpin := trans_pin
  dira[tpin]~~

PUB start_up_extended(trans_pin, frqpin)

  freqpin := frqpin
  tpin := trans_pin
  dira[tpin]~~
  dira[freqpin]~~
  transmit

PUB str(stringptr)

  repeat strsize(stringptr)
    out(byte[stringptr++])

PUB hex(value, digits)

  value <<= (8 - digits) << 2
  repeat digits
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))

PUB bin(value, digits)

'' Print a binary number

  value <<= 32 - digits
  repeat digits
    out((value <-= 1) & 1 + "0")
    
PUB help

  out("s")
  out("o")
  out("s")

PUB out(char) 

  case char
   "A", "a":
    dot
    dash
   "B", "b":
    dash
    dot
    dot
    dot
   "C", "c":
    dash
    dot
    dash
    dot
   "D", "d":
    dash
    dot
    dot
   "E", "e":
    dot
   "F", "f":
    dot
    dot
    dash
    dot
   "G", "g":
    dash
    dash
    dot
   "H", "h":
    dot
    dot
    dot
    dot
   "I", "i":
    dot
    dot
   "J", "j":
    dot
    dash
    dash
    dash
   "K", "k":
    dash
    dot
    dash
   "L", "l":
    dot
    dash
    dot
    dot
   "M", "m":
    dash
    dash
   "N", "n":
    dash
    dot
   "O", "o":
    dash
    dash
    dash
   "P", "p":
    dot
    dash
    dash
    dot
   "Q", "q":
    dash
    dash
    dot
    dash
   "R", "r":
    dot
    dash
    dot
   "S", "s":
    dot
    dot
    dot
   "T", "t":
    dash
   "U", "u":
    dot
    dot
    dash
   "V", "v":
    dot
    dot
    dot
    dash
   "W", "w":
    dot
    dash
    dash
   "X", "x":
    dash
    dot
    dot
    dash
   "Y", "y":
    dash
    dot
    dash
    dash
   "Z", "z":
    dash
    dash
    dot
    dot


   "1":
    dot
    dash
    dash
    dash
    dash
   "2":
    dot
    dot
    dash
    dash
    dash
   "3":
    dot
    dot
    dot
    dash
    dash
   "4":
    dot
    dot
    dot
    dot
    dash
   "5":
    dot
    dot
    dot
    dot
    dot
   "6":
    dash
    dot
    dot
    dot
    dot
   "7":
    dash
    dash
    dot
    dot
    dot
   "8":
    dash
    dash
    dash
    dot
    dot
   "9":
    dash
    dash
    dash
    dash
    dot
   "0":
    dash
    dash
    dash
    dash
    dash

PRI dot

  s.Synth("B", tpin, 400)
  waitcnt((clkfreq / 5) + cnt)
  s.Synth("B", tpin, 0)
  waitcnt((clkfreq / 2) + cnt)

PRI dash

  s.Synth("B", tpin, 400)
  waitcnt((clkfreq / 2) + cnt)
  s.Synth("B", tpin, 0)
  waitcnt((clkfreq / 2) + cnt)

PRI transmit

  s.Synth("A", freqpin, 90.4)

DAT

    
     
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}          