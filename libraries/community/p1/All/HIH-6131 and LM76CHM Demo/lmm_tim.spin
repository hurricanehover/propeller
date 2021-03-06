{{
┌──────────────────────────────────────────┐
│ LMM I2C Test Driver 1.1                  │
│ Author: Tim Moore                        │
│ Copyright (c) June 2010 Tim Moore        │
│ See end of file for terms of use.        │
└──────────────────────────────────────────┘

 Supports writing I2C device driver objects that use inline PASM

}}
CON
'  _clkmode = xtal1 + pll16x
'  _xinfreq = 5_000_000
  _clkmode        =             xtal1 + pll16x
  _xinfreq        =             5_000_000

{#define LMM                     'enable lmm
#define QUICKATAN2              'enable faster atan2
#define I2CDEBUG                'display debug messages when i2c fails}

OBJ
                                                        '1 Cog here
  uarts         : "pcFullDuplexSerial4FC"               '1 Cog for 4 serial ports
  button:       "Button"
  


VAR
  
  long ClockInputStack[32]
  long pulsecount

PUB main 

  

  uarts.Init                                            'Init serial ports

  uarts.AddPort(0, 31,30,-1,-1,-1,0,115200)

  uarts.Start                                           'Start the ports

  uarts.str(0, string("LMM HMC5843/ITG-3200 test", 13))

  cognew(ClockInput, @ClockInputStack)
  repeat
    uarts.str(0, string(13,"PC: "))
    uarts.dec(0, pulsecount)
    waitcnt(clkfreq*3 + cnt)


PUB ClockInput  | t, index 

  dira[13]~                                  ' set ClockPulsePin to input
  repeat
    'returns true only id button pressed, held for at least 80ms and released.
    if button.ChkBtnPulse(13, 1, 10)
      index++
      pulsecount += 1


                             'Transient as defined by the request so we won't count it.  