{{┌────────────────────────────────────┐
  │ MCP2515 driver                     │
  │ Author: Chris Gadd                 │
  │ Copyright (c) 2014 Chris Gadd      │
  │ See end of file for terms of use.  │
  └────────────────────────────────────┘

  PUB methods
    InitSPI(Clock_pin, MISO_pin, MOSI_pin, CS_pin, type, pull_up)               ' Starts either a SPIN (type = 0) or PASM (type = 1) SPI driver
                                                                                   The SPIN driver runs at ~19Kbps tx / ~26Kbps rx
                                                                                   The PASM driver runs at ~1.1Mbps
                                                                                   pull_up = 1 if a pull-up resistor is used on MOSI
    Stop                                                                        ' Stops the PASM SPI driver if running
    UseOscillator(osc_pin)                                                      ' Generates a 20MHz clock signal for the MCP2515 osc1 input
    SetMode(mode)                                                               ' Sets mode of operation for the MCP2515
                                                                                   NORMAL - Only mode that causes the MCP2515 to transmit, including acks
                                                                                   LOOPBACK - Connects the MCP2515 tx_buffer to the rx_buffer, useful for testing
                                                                                   LISTEN - Listens to the CAN bus, receives bytes into the rx_buffer, does not send acks
                                                                                   CONFIG - Bootup mode, must be in this mode to change bitrate and rx filters
    SetCanbusBitrate(bitrate)                                                   ' Set the bitrate to 1Mbps, 500Kbps, 250Kbps, 125Kbps, 62.5Kbps, or 31.25Kbps
    SetFilter(mask, mask_value, filter, filter_value)                           ' Configure the rx buffer to only store messages with specific IDs
    LoadTxBuffer(buffer, ident, data_length, d0, d1, d2 ,d3, d4 ,d5, d6, d7)    ' Writes all bytes into buffer 0, 1, or 2 for transmitting
    LoadTxStr(buffer, ident, @dlc)                                              ' Write bytes from a string
    LoadTxData(buffer, d0, d1, d2, d3, d4, d5, d6, d7)                          ' Only writes data bytes into the buffer, uses previously stored ID and data length
    LoadRTR(buffer, ident)                                                      ' Writes ident only, with the remote-transfer-request bit set, into buffer 0, 1, or 2
    SendTxBuffer(buffer)                                                        ' Queues buffer 0, 1, or 2 for transmitting.  Transmission begins when the bus is available
    ReadRxBuffer(bufferPtr)                                                     ' Read the entire contents of the lowest buffer (0 or 1) that has new data, stores data into
                                                                                   a buffer addressed by bufferPtr
                                                                                   returns #1 to indicate a standard or extended frame
                                                                                   returns #2 to indicate a remote-transfer request
    ReadRxData (bufferPtr)                                                      ' Same as above, but only reads the eight data byte locations
                                                                                   returns true if message received
                         
                         
    3V3  5V                                            
           MCP2551                                   
        │ ┌───────┐                                 
     ┣───┼─┤TxD    Rs├─┐               CAN bus         
     │ ┌─┼─┤Vss  CANH├─┼─────┳──    
     │  └─┤Vdd  CANL├─┼───┳─┼──    
     │   ┌─┤RxD  Vref├ │   │ │                         
     │   │ └─────────┘     62Ω                      
     │   │             │   └┳┘                         
     │   │             │   0.1nF                    
     │   │                                           
     │   │                                             
     │   │               3V3         
     │   │ MCP2515-18pin                             
     │   │ ┌───────┐   │      Both SPI drivers work with or without pull-ups, with straight or shared connections
     └───┼─┤TxCAN Vdd├───┘ │    ┌──────────────────────┐┌──────────────────────┐┌──────────────────────┐┌──────────────────────┐ 
         └─┤RxCAN Rst├─────┘    │                      ││                     ││                      ││                     │
           ┤      /CS├          │                      ││                     ││                      ││                     │
           ┤     MISO├          │ MISO────── prop in  ││ MISO────┼─ prop in  ││ MISO────┐            ││ MISO────┫            │
           ┤     MOSI├          │ MOSI────── prop out ││ MOSI────┻─ prop out ││ MOSI────┻─ prop I/O ││ MOSI────┻─ prop I/O │
           ┤      SCK├          │                      ││                      ││                      ││                      │
           ┤         ├          └──────────────────────┘└──────────────────────┘└──────────────────────┘└──────────────────────┘
           ┤Osc1     ├            Specify the pull-up resistor when initializing SPI - The MCP2515 has a built-in pull-up on MISO
         ┌─┤Vss      ├            Set MISO and MOSI to the same pin to use a shared connection
          └─────────┘            CS and SCK are always driven
         
}}
CON                             ' demo                         
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _CLK  = 19
  _MISO = 17
  _MOSI = 18
  _CS   = 16

CON

  MODE_NORMAL =   $00
  MODE_SLEEP =    $20
  MODE_LOOPBACK = $40
  MODE_LISTEN =   $60
  MODE_CONFIG =   $80

  CMD_RESET          = $C0
  CMD_WRITE          = $02
  CMD_READ           = $03
  CMD_BIT_MODIFY     = $05
  CMD_LOAD_TX_BUFFER = $40
  CMD_RTS            = $80
  CMD_READ_RX_BUFFER = $90
  CMD_READ_STATUS    = $A0
  CMD_RX_STATUS      = $B0

  REG_CNF1      = $2A
  REG_CNF2      = $29
  REG_CNF3      = $28

  REG_TXBnCTRL  = $30

  REG_CANSTAT   = $0E
  REG_CANCTRL   = $0F

  PASM = 1  
  SPIN = 0

VAR

  long  _xfer_address                     ' contains number of bytes to send, number of bytes to read, and address of buffer to store read bytes
  byte  sck,miso,mosi,cs                  ' all registers from _xfer_address to the final spi_buffer must be kept together and in this order for the
  byte  spi_buffer[14]                    '  PASM spi driver to work properly  
  byte  spi_driver, pullup, cog

OBJ
  FDS    : "FullDuplexSerial"   ' demo

VAR
  byte  rx_buffer[13]          
  
PUB demo 

  FDS.start(31,30,0,115200)
  
  waitcnt(cnt + clkfreq)
  fds.tx($00)

  InitSPI(_CLK,_MISO,_MOSI,_CS,SPIN,0)
  UseOscillator(0)                                      ' Use Prop pin 0 to generate an oscillator for the MCP2515
  SendCommand(CMD_RESET)
  SetCanbusBitrate(1_000_000)                           ' Set the BaudRatePrescaler for 1Mbps operation
  SetFilter(0,$7FF << (32 - 11),0,$78E << (32 - 11))    ' Set RxBuffer 0 to only receive messages with identifiers of $78E and $78F
  SetFilter(0,$7FF << (32 - 11),1,$78F << (32 - 11))
  SetFilter(1,0,2,%00000000000_010_000000000000000000)  ' The EXIDE bit must be set in a filter in order to receive extended frame messages,
                                                        '  even if the mask is all zeroes - buffer 1 filter 2 accepts every extended frame
  SetFilter(1,0,3,0)                                    ' The EXIDE bit must be clear in another filter in order to receive standard frame messages
                                                        '  buffer 1 filter 3 accepts every standard frame
  LoopBack_Demo

PUB Normal_Demo

'' Listen to the bus and send ACKs   
                 
  SetMode(MODE_NORMAL)                                  ' Normal mode is the standard operating mode of the       
                                                        ' MCP2515. In this mode, the device actively monitors all 
  repeat                                                ' bus messages and generates acknowledge bits, error      
    DemoReader                                          ' frames, etc. This is also the only mode in which the    
                                                        ' MCP2515 will transmit messages over the CAN bus.

PUB LoopBack_demo | id, dlc, d0, d1, d2, d3, d4, d5, d6, d7, i, n

  SetMode(MODE_LOOPBACK)                                ' Loopback mode will allow internal transmission of messages     
                                                        ' from the transmit buffers to the receive buffers           
  dlc := 0                                              ' without actually transmitting messages on the CAN          
  n := 0                                                ' bus. This mode can be used in system development           
  id := $780                                            ' and testing.

  LoadTxBufferStr(0,$123,@demo_buffer_string)           ' Load the tx buffer from a string
  SendTxBuffer(0)
  DemoReader

  LoadTxDataStr(0,@demo_data_string)                    ' Load just the data bytes from a string   
  SendTxBuffer(0)                                       '  uses the previously sent ident and data length
  DemoReader

  waitcnt(cnt + clkfreq)
                                      
  repeat                                                ' This demo transmits messages with incrementing IDs, data lengths, 
    id++                                                '  and data byte values.  Data length resets from 8 back to 0
    if dlc == 0                                         ' Transmits a remote transfer request (RTR) whenever data length is zero
      LoadRTR(0,id)                                     
    else                                                
      LoadTxBuffer(0,id,dlc,d0,d1,d2,d3,d4,d5,d6,d7)
    SendTxBuffer(0)                                     
                                                                                                                     
    DemoReader                                          
                                                                                                                     
    if ++dlc == 9                                                                                                    
      dlc := 0                                                                                                       
    if dlc                                                                                                           
      repeat i from 0 to dlc - 1                                                                                     
        d0[i] := n++                                                                                                 
    waitcnt(cnt + clkfreq / 20)

PUB DemoReader | ident, frame, i

  if frame := ReadRxBuffer(@rx_buffer)                                                      ' ReadRxBuffer returns 0 - no message, 1 - normal message, or 2 - RTR
    ident := rx_buffer[0] << 3 | rx_buffer[1] >> 5                                          ' Buffers 0 through 3 contain ID information                    
    if rx_buffer[1] & $08                                                                   '  The ID needs to be reformatted into 11 or 29 bits depending  
      ident := ident << 18 | (rx_buffer[1] & 3) << 16 | rx_buffer[2] << 8 | rx_buffer[3]    '   on whether a standard or extended frame is received         
      fds.hex(ident,8)                                                                      '  Bit 4 of rx_buffer[1] contains the EXIDE flag                
    else
      fds.hex(ident,3)
    fds.tx($09)
    if frame == 1    
      if rx_buffer[4] & $0F                                                                 ' rx_buffer[4] contains data length   
        repeat i from 0 to rx_buffer[4] & $0F - 1                                            
          fds.hex(rx_buffer[i + 5],2)                                                       ' rx_buffers[5] through [12] contain the data
          fds.tx(" ")
    if frame == 2
      fds.str(string("remote transmission request"))
    fds.tx($0D)

DAT

demo_buffer_string      byte      8,$01,$23,$45,$67,$89,$AB,$CD,$EF
demo_data_string        byte      $11,$22,$33,$44,$55,$66,$77,$88
    
PUB InitSPI(clock_pin, miso_pin, mosi_pin, cs_pin, type, pull_up)

  sck  := clock_pin
  miso := miso_pin
  mosi := mosi_pin
  cs   := cs_pin

  pullup := pull_up & 1

  Stop
  
  if type == SPIN
    spi_driver := SPIN
    dira[sck] := 1
    dira[mosi] := 1
    dira[cs] := 1
    outa[cs] := 1
  else
    spi_driver := PASM
    cog := cognew(@pasm_spi_driver,@_xfer_address) + 1

PUB Stop

  if cog
    cogstop(cog~ - 1)

PUB UseOscillator(osc_pin)

'' Use ctra to generate a 20MHz signal connected to the MCP2515 osc1 pin

  ctra := %00010_101 << 23 | osc_pin
  frqa := 268_435_456
  dira[osc_pin] := 1

PUB SetMode(mode) | t

'' Mode will not change until all pending message transmissions are complete, waits 10ms for mode to change, then fails

  ModifyRegister(REG_CANCTRL,%111_00000, mode)
  t := cnt + clkfreq / 100
  repeat until ((ReadRegister(REG_CANSTAT) & %111_00000) == mode) or cnt - t > 0
  if cnt - t > 0
    return false
  else
    return true    
  
PUB SetCanbusBitrate(bitrate) | SJW, BRP, BTLMODE, SAM, PHSEG1, PRSEG, SOF, WAKFIL, PHSEG2
{{
  This method requires a 20MHz clock on the MCP2515 oscillator
  Each CANbus bit is divided into four segments, each segment lasts for a certain time, expressed as TQ (Time Quanta)

  ┌─────────┬─────────┬───────────┬─────────────────┐
  │ SyncSeg │ PropSeg │ PhaseSeg1 │    PhaseSeg2    │
  └─────────┴─────────┴───────────┴─────────────────┘
  │    1         1          1             2        │
  │                               Sample point      │
  │────────────────── One bit ────────────────────│
             
  The SyncSeg is 1TQ.  PropSeg, PS1, and PS2 are configurable
    PropSeg   : 1 - 8
    PhaseSeg1 : 1 - 8
    PhaseSeg2 : 2 - 8

  The MCP2515 attempts to resynchronize to a faster or slower transmitter by adjusting PS1 and PS2 in order to keep the same sample point
    The amount of adjustment is determined by the Synchronization Jump Width (SWJ), and ranges from 1 to 4 TQ  

  This method is coded to use 5TQ per bit, with a 20MHz oscillator.
    Bitrates are set by varying the Baud Rate Prescaler (BRP)
    1TQ = 2 x (BRP + 1) / Fosc

    For 500Kbps:
      1 bit is 2us, each bit is 5TQ, therefore each TQ is 400ns
      400ns * 20MHz = 8.  Divide by 2 and subtract 1, BRP = 3

    For 1Mbps:
      1 bit is 1us, each TQ is 200ns
      200ns * 20MHz = 4.  Divide by 2 and subtract 1, BRP = 1

  I'm sure there's some clever way to adjust the oscillator, TQ per bit, and baud-rate prescaler to allow for any arbitrary bitrate,
   but for now, allowable bitrates are 1Mbps, 500Kbps, 250Kbps,...
}}

  case bitrate
    1_000_000 : BRP := %000001
    500_000   : BRP := %000011
    250_000   : BRP := %000111
    125_000   : BRP := %001111
    62_500    : BRP := %011111
    31_250    : BRP := %111111
    
  SJW     := %00                ' Synchronization Jump Width Length bits + 1
' BRP     := BRP                ' Baud rate prescaler: TQ = 2 x (BRP + 1) / Fosc
  BTLMODE := %1                 ' Length of PS2 determined by PHSEG22:PHSEG20 bits of CNF3
  SAM     := %0                 ' Bus line is sampled once at the sample point
  PHSEG1  := %000               ' PS1 Length bits + 1
  PRSEG   := %000               ' Propagation Segment Length bits + 1
  SOF     := %0                 ' CLKOUT pin enabled for clockout function
  WAKFIL  := %0                 ' Wake-up filter disabled
  PHSEG2  := %001               ' PS2 Length bits + 1 (min valid setting is 2TQ)

  WriteRegister(REG_CNF1,(SJW & $3) << 6 | BRP & $3F)
  WriteRegister(REG_CNF2,(BTLMODE & %1) << 7 | (SAM & %1) << 6 | (PHSEG1 & $7) << 3 | PRSEG & $7)
  WriteRegister(REG_CNF3,(SOF & $1) << 7 | (WAKFIL & $1) << 6 | PHSEG2 & $7)

PUB LoadTxBuffer(buffer, ident, data_length, d0, d1, d2 ,d3, d4 ,d5, d6, d7) | i
{{
  This method loads ID and data into buffer 0, 1, or 2
}}

  if ReadStatus(CMD_READ_STATUS) & (|< (buffer * 2 + 2))                        ' buffers 0, 1, 2 are mapped to bits 2, 4, 6
    return false                                                                ' The TXREQ bit must be clear before writing to the buffer

  spi_buffer[0] := CMD_LOAD_TX_BUFFER | (buffer * 2)                            
  if ident > $7FF                                                               
    spi_buffer[1] := ident >> 21                                                
    spi_buffer[2] := ident >> 13 & $E0 | $08 | ident >> 16 & 3            
    spi_buffer[3] := ident >> 8
    spi_buffer[4] := ident
  else                                                                          
    spi_buffer[1] := ident >> 3                                 
    spi_buffer[2] := ident << 5
  spi_buffer[5] := data_length <#= 8

  repeat i from 0 to data_length - 1 <# 7
    spi_buffer[i + 6] := d0[i]
  xfer(6 + data_length,0,0)
  return true

PUB LoadTxBufferStr(buffer, ident, strPtr) | data_length, d0, d1, d2, d3, d4, d5, d6, d7, i

  data_length := byte[strPtr]
  i := 0
  repeat byte[strPtr++]
    d0[i++] := byte[strPtr++]

  if LoadTxBuffer(buffer, ident, data_length, d0, d1, d2 ,d3, d4 ,d5, d6, d7)
    return true              
  
PUB LoadTxData(buffer, d0, d1, d2, d3, d4, d5, d6, d7) | i
{{
  This method only loads data bytes into buffer 0, 1, or 2.
  Messages are sent using the previously loaded ID and data length
}}

  if ReadStatus(CMD_READ_STATUS) & (|< (buffer * 2 + 2))                        ' buffers 0, 1, 2 are mapped to bits 2, 4, 6
    return false                                                                ' The TXREQ bit must be clear before writing to the buffer

  spi_buffer[0] := CMD_LOAD_TX_BUFFER | (buffer * 2) | 1
  repeat i from 0 to 7
    spi_buffer[i + 1] := d0[i]
  xfer(9,0,0)
  return true

PUB LoadTxDataStr(buffer, strPtr) | d0, d1, d2, d3, d4, d5, d6, d7, i

  i := 0
  repeat 8
    d0[i++] := byte[strPtr++]

  if LoadTxData(buffer, d0, d1, d2 ,d3, d4 ,d5, d6, d7)
    return true              

PUB LoadRTR(buffer, ident)
  
  if ReadStatus(CMD_READ_STATUS) & (|< (buffer * 2 + 2))                        ' buffers 0, 1, 2 are mapped to bits 2, 4, 6
    return false                                                                ' The TXREQ bit must be clear before writing to the buffer

  spi_buffer[0] := CMD_LOAD_TX_BUFFER | (buffer * 2)                            ' RTR only sends ID and data length, with the RTR bit set
  if ident > $7FF                                                               '  The MCP2515 will still send as many data bytes as are                      
    spi_buffer[1] := ident >> 21                                                '  indicated by the DLC, even though the protocol says the
    spi_buffer[2] := ident >> 13 & $E0 | $08 | ident >> 16 & 3                  '  data fields are unused                                   
    spi_buffer[3] := ident >> 8
    spi_buffer[4] := ident
  else                                                                          
    spi_buffer[1] := ident >> 3                                 
    spi_buffer[2] := ident << 5
  spi_buffer[5]   := %0100_0000                                                 ' Send the RTR bit and zero data bytes
  xfer(6,0,0)
  return true

PUB SendTxBuffer(buffer)

'' Queues buffer 0, 1, or 2 for transmission.  Transmission begins when CANbus is available

  SendCommand(CMD_RTS | |< buffer)   
    
PUB ReadRxBuffer(bufferPtr) : frame | buffer, in_bytes

  buffer := ReadStatus(CMD_RX_STATUS)
  if buffer & %11_0_00_000
    if buffer & %01_0_00_000
      spi_buffer[0] := CMD_READ_RX_BUFFER | %000        ' read from RXB0SIDH
    else
      spi_buffer[0] := CMD_READ_RX_BUFFER | %100        ' read from RXB1SIDH
    if buffer & %00_0_01_000                            
      in_bytes := 5                                     ' only need to read 5 bytes if a remote-transfer-request
      frame := 2                                        ' return 2 to indicate a RTR
    else
      in_bytes := 13                                    ' read all 13 bytes if a standard or extended frame
      frame := 1                                        ' return 1 for standard or extended frame
    xfer(1,in_bytes,bufferPtr)                          ' ideally, SPI would only read as many bytes as indicated by the DLC, 
'   return frame                                        '  however the DLC byte is only returned when using this method.  
  else                                                  '  The ReadRxData method below does not return DLC at all,                
    return false                                        '  and then contents of rx_buffer[4] contain ordinary data

PUB ReadRxData (bufferPtr) | buffer

  if buffer := ReadStatus(CMD_READ_STATUS) & %11
    if buffer & %01
      spi_buffer[0] := CMD_READ_RX_BUFFER | %010        ' read from RXB0D0
    else
      spi_buffer[0] := CMD_READ_RX_BUFFER | %110        ' read from RXB1D1
    xfer(1,8,bufferPtr)                                 ' This method does not read DLC, therefore all eight data bytes must be read
    return true
  else
    return false

PUB SetFilter(mask, mask_value, filter, filter_value) | n
{{
  Must be in configuration mode to set acceptance masks and filters for the receive buffers
    Buffer 0 uses Mask 0 and Filters 0 and 1
    Buffer 1 uses Mask 1 and Filters 2 through 5

    Standard frame:                                       Extended frame:                     
      Ident             Data0    Data1                      IdentA          IdentB            
                                                                                         
     %iiiiiiiiiii_00000_dddddddd_dddddddd                  %iiiiiiiiiii_010_iiiiiiiiiiiiiiiiii
    
  To only receive messages with ID $78F:                  In order to receive any extended frame message,      
   Set the mask to   $FFE0_0000  ($7FF << (32 - 11))        the EXIDE bit must be set in the filter.            
   Set the filter to $F1E0_0000  ($78F << (32 - 11))      It rejects messages if that bit is not set,
                                                           even if the mask is all zeroes.
                                                          If the EXIDE bit is set, the filter then rejects all
                                                           standard frames.
}}
  spi_buffer[0] := CMD_WRITE
  spi_buffer[1] := $20 + mask * 4                         
  spi_buffer[2] := mask_value >> 24
  spi_buffer[3] := mask_value >> 16
  spi_buffer[4] := mask_value >> 8
  spi_buffer[5] := mask_value
  xfer(6,0,0)

  spi_buffer[0] := CMD_WRITE
  case filter
    0..2: spi_buffer[1] := filter * 4
    3..5: spi_buffer[1] := filter * 4 + 4
  spi_buffer[2] := filter_value >> 24
  spi_buffer[3] := filter_value >> 16
  spi_buffer[4] := filter_value >> 8
  spi_buffer[5] := filter_value
  xfer(6,0,0)

PUB SendCommand(command)

  spi_buffer[0] := command

  xfer(1,0,0)

PUB ReadStatus(address) : status

  spi_buffer[0] := address

  xfer(1,1,@status)              
  
PUB WriteRegister(address, data)

  spi_buffer[0] := CMD_WRITE
  spi_buffer[1] := address
  spi_buffer[2] := data         
  xfer(3,0,0)

PUB ReadRegister(address) : data

  spi_buffer[0] := CMD_READ
  spi_buffer[1] := address
  xfer(2,1,@data)

PUB ModifyRegister(address, mask, value)

  spi_buffer[0] := CMD_BIT_MODIFY
  spi_buffer[1] := address
  spi_buffer[2] := mask
  spi_buffer[3] := value
  xfer(4,0,0)

PUB xfer(out_bytes, in_bytes, in_ptr) | out_ptr

  if spi_driver == PASM
    _xfer_address := in_ptr << 16 | pullup << 8 | in_bytes << 4 | out_bytes
    repeat until _xfer_address == 0
  else
    out_ptr := @spi_buffer
    outa[CS] := 0
    repeat out_bytes
      tx(byte[out_ptr++])
    repeat in_bytes
      byte[in_ptr++] := rx
    outa[CS] := 1

PRI tx(data)

  if not pullup                                         
    dira[MOSI] := 1

  repeat 8
    if pullup
      dira[MOSI] := !data >> 7 & 1
    else
      outa[MOSI] := data >> 7 & 1
    outa[SCK] := 1
    outa[SCK] := 0
    data <<= 1

PRI rx : data

  data := 0

  dira[MOSI] := 0
  
  repeat 8
    outa[SCK] := 1
    data := data << 1 | ina[MISO]
    outa[SCK] := 0  

DAT                     org
pasm_spi_driver
                        mov       t1,par
                        mov       xfer_address,t1                               ' xfer_address contains out_bytes, in_bytes, and in_ptr
                        add       t1,#4
                        mov       sck_mask,#1
                        rdbyte    t2,t1
                        shl       sck_mask,t2
                        add       t1,#1
                        mov       miso_mask,#1
                        rdbyte    t2,t1
                        shl       miso_mask,t2
                        add       t1,#1
                        mov       mosi_mask,#1
                        rdbyte    t2,t1
                        shl       mosi_mask,t2
                        add       t1,#1
                        mov       cs_mask,#1
                        rdbyte    t2,t1
                        shl       cs_mask,t2
                        add       t1,#1
                        mov       spi_address,t1
                        or        dira,sck_mask
                        or        dira,cs_mask
                        or        outa,cs_mask
'......................................................................................................................
wait_for_byte
                        rdlong    t1,xfer_address             wz                ' xfer_address contains the number of bytes to send, the number
          if_z          jmp       #$-1                                          '  of bytes to receive, and an address to store the receive bytes
                        mov       out_counter,t1                                '  encoded as:
                        and       out_counter,#$F                               '  ┌────address────┐          rx  tx
                        mov       in_counter,t1                                 '                              
                        shr       in_counter,#4                                 '  aaaaaaaa_aaaaaaaa_xxxxxxxp_iiiioooo
                        and       in_counter,#$F                                '                           
                        mov       in_address,t1                                 '                           pull_up
                        shr       in_address,#16                                '
                        mov       spi_ptr,spi_address
                        test      t1,#$0000_0100              wz                ' set z if mosi does not have a pull_up resistor
                        andn      outa,cs_mask                                  ' Lower the chip select line to start
xfer_out                                                                     
                        rdbyte    spi_byte,spi_ptr                              ' Every message sends at least one byte
                        call      #xfer_byte   
                        add       spi_ptr,#1
                        djnz      out_counter,#xfer_out
                        tjz       in_counter,#end                               ' Can return from 0 to 13 bytes, end if zero
xfer_in
                        call      #xfer_byte                                    ' Read one byte
                        wrbyte    spi_byte,in_address                           ' Write into the rx_buffer
                        add       in_address,#1                                 
                        djnz      in_counter,#xfer_in
end
                        mov       t1,#0                                         ' Write 0 into xfer_address to signal completion to the SPIN routine
                        wrlong    t1,xfer_address
                        or        outa,cs_mask                                  ' Raise the chip select line to finish
                        jmp       #wait_for_byte
'======================================================================================================================
xfer_byte                                                                       ' This routine both sends and receives, with and without a pull up,
                                                                                '  and with miso and mosi combined or seperated
                        shl       spi_byte,#32 - 8                              ' Move byte to the msb
                        mov       bit_counter,#8                                ' Prepare to send eight bits
:loop
                        shl       spi_byte,#1                 wc,nr             ' test the msb
          if_z          or        dira,mosi_mask                                ' set/clear mosi
          if_z          muxc      outa,mosi_mask                                '  z is set if no pull ups
          if_nz         muxnc     dira,mosi_mask
                        mov       t2,#$6                                        ' need a short delay when using pull ups
                        djnz      t2,#$
                        or        outa,sck_mask                                 ' up-clock
                        andn      dira,mosi_mask
                        test      miso_mask,ina               wc                ' test miso
                        andn      outa,sck_mask                                 ' down-clock
                        rcl       spi_byte,#1                                   ' rotate miso into the lsb, rotate the msb out
                        djnz      bit_counter,#:loop                            ' repeat for eight bits
xfer_byte_ret           ret                                                     
'======================================================================================================================
sck_mask                res       1
miso_mask               res       1
mosi_mask               res       1
cs_mask                 res       1
xfer_address            res       1
out_counter             res       1
in_counter              res       1
in_address              res       1
SPI_byte                res       1
SPI_address             res       1
SPI_ptr                 res       1
byte_counter            res       1
bit_counter             res       1
t1                      res       1
t2                      res       1

                        fit