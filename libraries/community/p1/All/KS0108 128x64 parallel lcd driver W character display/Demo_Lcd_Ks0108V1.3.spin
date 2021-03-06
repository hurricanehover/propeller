''************************************************
''*  Graphics Demo                               *
''*  Author: Chip Gracey                         *
''*  Modified by Erik Friesen and Juan Velasquez *
''*  Copyright (c) 2005 Parallax, Inc.           *               
''*  See end of file for terms of use.           *               
''************************************************

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  _stack = ($4000  ) >> 2   'accomodate display memory and stack

  x_tiles = 8
  y_tiles = 4

  paramcount = 14       
  bitmap_base = $4000
  
  lines = 5
  thickness = 2
  

VAR

  byte  x[lines]
  byte  y[lines]
  byte  xs[lines]
  byte  ys[lines]
  long  lcdpointer

OBJ

  gr   : "graphics"
  text :"Ks0108V1.3"

PUB start | i, j, k, kk, dx, dy, pp, pq, rr, numx, numchr ,a,b,c,tot,d,tot2,tmp

  lcdpointer:=text.start
  'text.start
  'lc.start
  initialdemo
  'init bouncing lines
  i := 1001
  j := 123123
  k := 8776434
  repeat i from 0 to lines - 1
    x[i] := ?j // 64
    y[i] := k? // 48
    repeat until xs[i] := k? ~> 29
    repeat until ys[i] := ?j ~> 29

  gr.start
  gr.setup(8, 4, 64, 32, bitmap_base)

  repeat

    'clear bitmap
    gr.clear

    'draw spinning triangles
    gr.colorwidth(1,0)
    repeat i from 1 to 8
      gr.vec(0, 0, (k & $7F) << 3 + i << 5, k << 6 + i << 8, @vecdef)

    'draw expanding mouse crosshairs
    gr.colorwidth(1,k>>2)
    gr.colorwidth(1,k)
    gr.arc(0,0,80,30,-k<<5,$2000/9,9,0)

    'step bouncing lines
    repeat i from 0 to lines - 1
      if ||~x[i] > 60
        -xs[i]
      if ||~y[i] > 40
        -ys[i]
      x[i] += xs[i]
      y[i] += ys[i]

    'draw bouncing lines
    gr.colorwidth(1,thickness)
    gr.plot(~x[0], ~y[0])
    repeat i from 1 to lines - 1
      gr.line(~x[i],~y[i])
    gr.line(~x[0], ~y[0])

    'draw spinning stars and revolving crosshairs and dogs
    gr.colorwidth(1,0)
    repeat i from 0 to 7
      gr.vecarc(40,15,15,15,-(i<<10+k<<5),$40,-(k<<7),@vecdef2)

    'draw small box with text
    gr.colorwidth(1,4)
    gr.box(0,-28,60,12)
    gr.textmode(1,1,6,5)
    gr.colorwidth(0,0)
    gr.text(32,-22,@pchip)

    'draw incrementing digit
    if not ++numx & 7
      numchr++
    if numchr < "0" or numchr > "9"
      numchr := "0"
    gr.textmode(8,8,6,5)
    gr.colorwidth(1,8)
    'text.out("a")

    text.writegraphics
    gr.copy($7000)
     waitcnt(2000000+cnt)

   k++
    
pub initialdemo|a
a:=0
repeat 300
  if a++==1000
    a:=0
  text.out($1)
  text.str(string($d,1,"Dcml pnt 2 ",$d,2,$a,10))
  text.dec(a,2,5)
  text.str(string($d,3,$b,1,"Size 3"))
  text.str(string($d,4,$b,1,"Size 4"))
  text.box(18,80,30,110,0,1)
  if a&%10000
    text.out($c1)
  else
    text.out($c2)
  text.str(string($d,1,$b,14,$a,14,$b,2,$e,4,$f,1,"Box",$c1))
DAT


vecdef                  word    $4000+$2000/3*0         'triangle
                        word    50
                        word    $8000+$2000/3*1+1
                        word    50
                        word    $8000+$2000/3*2-1
                        word    50
                        word    $8000+$2000/3*0
                        word    50
                        word    0

vecdef2                 word    $4000+$2000/12*0        'star
                        word    50
                        word    $8000+$2000/12*1
                        word    20
                        word    $8000+$2000/12*2
                        word    50
                        word    $8000+$2000/12*3
                        word    20
                        word    $8000+$2000/12*4
                        word    50
                        word    $8000+$2000/12*5
                        word    20
                        word    $8000+$2000/12*6
                        word    50
                        word    $8000+$2000/12*7
                        word    20
                        word    $8000+$2000/12*8
                        word    50
                        word    $8000+$2000/12*9
                        word    20
                        word    $8000+$2000/12*10
                        word    50
                        word    $8000+$2000/12*11
                        word    20
                        word    $8000+$2000/12*0
                        word    50
                        word    0

pixdef                  word                            'crosshair
                        byte    2,7,3,3
                        word    %%00333000,%%00000000
                        word    %%03020300,%%00000000
                        word    %%30020030,%%00000000
                        word    %%32222230,%%00000000
                        word    %%30020030,%%02000000
                        word    %%03020300,%%22200000
                        word    %%00333000,%%02000000

pchip                   byte    "Rapido?",0           'text

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