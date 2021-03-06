{{
Brownout Detector Demo Program.

    By Don Starkey
    Don@StarkeyMail.com
    BrownDetect Ver. 1.1
    10/12/2011


                            47k         +3.3     1N4003 x 2-Places
               ───┐  ┌────────────┐           Both diodes clamp voltage between 0 & 3.3Vdc.
        120Vac    ││ 12Vac  ┌───╋──┘
               ───┘               └─────────── To Propeller Input Pin 20 (I/O 15)  
                                         10k

    The 12Vac from the transformer secondary is used to power the Propeller circuit via appropriate voltage regulators.
    I use a 5Vdc switching regulator and then a 3.3V LDO regulator to power the propeller which gives plenty of time to write
    out configuration variables back to EEPROM in the event of a power loss or just turning off the power.
   

    I/O 15, Pin 20 - Clipped AC from transformer @ 60-Hz. for brown out detection.

    I/O 28, Pin 37 - SCL I2C
    I/O 39, Pin 38 - SDA I2C
    I/O 30, Pin 39 - Serial Communications
    I/O 31, Pin 40 - Serial Communications Also Bridge pin

Notes:
    When you "F11 - Load EEPROM", the variables from the DAT section below are used in your program.
    Change these variables at will within your program.
    When you power down or have a power loss, these variables are copied to their respective locations in EEPROM, overwriting
    the values from your original "F11- Load EEPROM".  This is done in the REPEAT loop when the variable Power_Good is cleared to 0.
    If you have a lot of variables to save, you will need a large filter capacitor on your power supply to assure enough time to save them.


}}
  

CON                  
  _CLKMODE      = XTAL1 + PLL16X                         
  _XINFREQ      = 5_000_000
  
VAR
    long    Power_Good             ' Power Good Variable. 0=Power Fail, save EEProm, non-0 = Power Good
    long    DetectPin

OBJ
    BrownDet    :"BrownDetect"          ' Actual Brownout Detector by
    lcd         :"lcd_16X2_8BIT"        ' Not actually required, just here for DEMO purposes
    eeprom      :"Propeller EEprom"     ' How I store / retreive variables when powering down.
    

dat

' Configuration Variables to/from EEprom
' All vars between Cycles and ConfigVars will be restored by VarRestore

Variable1   Long      1         ' Variable 1 to be saved in the event of a power loss
Variable2   Long      2         ' Variable 2 to be saved in the event of a power loss
Variable3   Long      3         ' Variable 3 to be saved in the event of a power loss
Variable4   Long      4         ' Variable 4 to be saved in the event of a power loss
Variable5   Long      5         ' Variable 5 to be saved in the event of a power loss
Variable6   Long      6         ' Variable 6 to be saved in the event of a power loss
Variable7   Long      7         ' Variable 7 to be saved in the event of a power loss

TableEnd    

    
PUB Start 

    DetectPin       :=  18      ' Input pin number, 60-Hz square wave from transformer
 

    Power_Good:=BrownDet.start(DetectPin)                   ' Returns address of Power Good variable, save it for later

    BrownDet.LineFreqSimulator(DetectPin)                          ' Remove this line for actual usage, helpful for debugging.
    
    lcd.start

    eeprom.VarRestore(@Variable1,@TableEnd)                 ' Retrieve the variables from EEPROM


    repeat
    
        '********* Save EEProm if power failure. Check memory location(power_good), if 0 then power fail
        
        if long[power_good] == 0                            ' Power Failure detected, save EEPROM

            eeprom.VarBackup(@Variable1,@TableEnd)          ' Save all variables to EEPROM if power failure
            lcd.move(1,1)
            lcd.str(string("Phase Loss.     "))
            lcd.move(1,2)
            lcd.str(string("Memory saved.   "))
            
            repeat while long[power_good]==0                ' Wait for power fail detect routine to finish.
                       
'            waitcnt(clkfreq*2+cnt)
            lcd.clear                                    

        lcd.move(1,1)
        lcd.str(string("Your program is"))
        lcd.move(1,2)
        lcd.str(string("running "))
        lcd.hex(long[power_good],8)
        


      