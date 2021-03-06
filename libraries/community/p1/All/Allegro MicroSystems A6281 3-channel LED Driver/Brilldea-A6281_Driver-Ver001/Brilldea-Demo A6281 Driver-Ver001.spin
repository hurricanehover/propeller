''**************************************
''
''  Demo of Brilldea's Allegro A6281 Driver Ver. 00.1
''
''  Timothy D. Swieter, E.I.
''  Brilldea - purveyor of prototyping goods
''  www.brilldea.com
''
''  Copyright (c) 2009 Timothy D. Swieter, E.I.
''  See end of file for terms of use.
''
''  Updated: April 11, 2009
''
''Description:
''
''      This is a simple demo program for running the
''      the Brilldea PolkaDOTs which uses the Allegro
''      MicroSystems A6281 three channel LED driver.
''
''
''Reference:
''      Allegro MicroSystems A6281 data sheet
''      Brilldea PolkaDOT-51 schematic and data sheet
''      Brilldea-A6281 driver-Ver001.spin
''
''To do:
''
''Revision Notes:
'' 0.1  Start of coding
''
''**************************************
CON               'Constants to be located here
'***************************************                       

  '***************************************
  ' Processor Settings
  '***************************************
  _clkmode = xtal1 + pll16x     'Use the PLL to multiple the external clock by 16
  _xinfreq = 5_000_000          'An external clock of 5MHz. is used (80MHz. operation)

  '***************************************
  ' System Definitions     
  '***************************************

  _OUTPUT       = 1             'Sets pin to output in DIRA register
  _INPUT        = 0             'Sets pin to input in DIRA register  
  _HIGH         = 1             'High=ON=1=3.3v DC
  _ON           = 1
  _LOW          = 0             'Low=OFF=0=0v DC
  _OFF          = 0
  _ENABLE       = 1             'Enable (turn on) function/mode
  _DISABLE      = 0             'Disable (turn off) function/mode

  '***************************************
  ' I/O Definitions
  '***************************************
  
  '~~~~Propeller Based I/O~~~~
  _PolkaDOT_ci  = 16            'A6281 clock input
  _PolkaDOT_sdi = 19            'A6281 serial data input
  _PolkaDOT_li  = 18            'A6281 latch input
  _PolkaDOT_oei = 17            'A6281 output enable intput

  '***************************************
  ' LED Chain Definitions
  '***************************************

  _PixelsperChain = 5           'Number of pixels in a chain, shouldn't be larger than 250

  '***************************************
  ' Misc Definitions
  '***************************************

  'none

'**************************************
VAR               'Variables to be located here
'***************************************

  'Pixel display data arrays
  long  PixelMemoryOffScrn[_PixelsperChain]
  long  PixelMemoryOnScrn[_PixelsperChain]

'***************************************
OBJ               'Object declaration to be located here
'***************************************

  PolkaDOT      : "Brilldea-A6281 Driver-Ver001.spin"   'Brilldea A6281 driver

'***************************************
PUB main | t0, pix, clr 'The first PUB in the file is the first one executed
'***************************************

  '**************************************
  ' Initialize the hardware
  '**************************************

  'none                                
  
  '**************************************
  ' Initialize the variables
  '**************************************
                  
  'none                                                                                                

  '**************************************
  ' Start the processes in their cogs
  '**************************************

  'Start the PolkaDOT driver
  PolkaDOT.start(_PolkaDOT_ci, _PolkaDOT_sdi, _PolkaDOT_li, _PolkaDOT_oei)

  'Set the initiali configuration
  PolkaDOT.BufferConfiguration(@PixelMemoryOnScrn, _PixelsperChain, 0)
  
  '**************************************
  ' Begin
  '**************************************

  'Infinite loop
  repeat

    '~~~~~~Fading~~~~~~
    'Fade the red from off to full on - applies to all pixels
    repeat t0 from 0 to 1023
      repeat pix from 0 to _PixelsperChain
        PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, t0, 0, 0)

      PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, true, false)
      
      PauseMSec(1)

    'Fade the green from off to full on - applies to all pixels
    repeat t0 from 0 to 1023
      repeat pix from 0 to _PixelsperChain
        PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, 0, t0, 0)
        
      PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, true, false)
      
      PauseMSec(1)

    'Fade the blue from off to full on - applies to all pixels
    repeat t0 from 0 to 1023
      repeat pix from 0 to _PixelsperChain
        PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, 0, 0, t0)

      PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, true, false)
      
      PauseMSec(1)


    '~~~~~~Strobing~~~~~~
    'Set the pixels to all white
    repeat pix from 0 to _PixelsperChain
      PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, 1023, 1023, 1023)

    PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, true, false)

    'toggle the A6281 output enable to cause the strobe
    repeat 10
      PolkaDOT.OutputEnable(false)
      PauseMsec(100)
      PolkaDOT.OutputEnable(true)
      PauseMsec(20) 

    'Reset the pixels to off
    repeat pix from 0 to _PixelsperChain
      PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, 0, 0, 0)

    PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, true, false)


    '~~~~~~Individual Control~~~~~~
    clr := 255
    
    repeat pix from 0 to _PixelsperChain
      PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, clr, 0, 0)
      PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, false, false)
      PauseMSec(500)

    PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, true, false)

    repeat pix from 0 to _PixelsperChain
      PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, 0, 255, 0)
      PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, false, false)
      PauseMSec(500)

    PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, true, false)

    repeat pix from 0 to _PixelsperChain
      PolkaDOT.setPixel(@PixelMemoryOffScrn, pix, 0, 0, 255)
      PolkaDOT.updatePixels(@PixelMemoryOnScrn, @PixelMemoryOffScrn, _PixelsperChain, false, false)
      PauseMSec(500)

  return

'***************************************
PRI PauseMSec(Duration)
'***************************************
'' Pause execution in milliseconds.
'' Duration = number of milliseconds to delay
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)
    
  return

'***************************************
DAT
'***************************************

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