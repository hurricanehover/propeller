{{
┌──────────────────────┐
│ Benky's ConfigReader │
├──────────────────────┴───────────────────────┐
│  Interface  :  1 text buffer                 │
│                1 parameter buffer            │
│                                              │
│  both buffers are under control of the       │
│  code using the ConfigReader. So, if the     │
│  ConfigReader did it's job the buffers can   │
│  used otherwise.                             │
├──────────────────────────────────────────────┤
│  By      : Benky (aka MagIO2)                │
│  Date    : 2010-04-25                        │
│  Version : 0.9                               │
│  License : MIT                               │
└──────────────────────────────────────────────┘

This object is for reading an parsing a config file, but it needs some support by
the code which uses this object. The reason is that this object does not put limits on the
place where to find the config and it has no driver for data-access (for example the
SD card driver). So the disadvantage of the need of additional code in the 'user' program
is compensated by the advantage of less usage of memory (having a SD driver in object and
user program) and independency of the storage device in general.

The usage is like a ping-pong game. The parser is called and tells what's the next step:
1. RET_LOAD_NEXT means that the next bunch of 512 bytes need to be loaded to the address
given in bytes 1 and 2 of the return value.
2. RET_PAR_FOUND means that a line containing parameters has been found and can be
processed by the program.
3. RET_DONE means that the file end has been reached

The code needed in the user program is not to big (this is extracte from TestCR):
cr is the ConfigReader object
sd is the SD card driver
buffer is the array of 512+ bytes for loading parts of the file
all other symbols you find are variables

  prsd:=cr#RET_LOAD_NEXT + @buffer<<8
  repeat while prsd<>cr#RET_DONE
    case prsd & $ff
      cr#RET_LOAD_NEXT:
        badr := (prsd>>8) & $ffff
        rd := sd.pread( badr, 512 )
        
      cr#RET_PAR_FOUND:
        case par_list[0]
          ' HERE COMES THE LIST OF HASH-VALUES AND THE CODE YOU WANT TO EXECUTE FOR
          ' PROCSSING THE PARAMETERS
            
    prsd := cr.parse( rd )
    rd:=0

What does a config-file look like:
1. you can have comment lines. Inline comments are currently not supported.

' comment line which is OK
config1 1 10 test ' this is not allowed
   
2. You can have empty lines, but they should not contain whitespaces, otherwise
   they are parsed. Most likely this won't harm, but waste runtime.
3. The separator for a configuration line is the space character.
4. A configuration line starts with a word/number which is translated to a hash value.
5. All other numbers are parsed and stored in a long. Numbers have the same format as
   numbers in SPIN: 1001 for decimal, $3af for hex or %100100 for binary. Float is
   currently not supported. The result is stored in the parameter list.
6. All other non numbers are treated like a string. The next separator (space) will then
   be replaced by a stringend (0). The start address of the string will be stored in the
   parameter list.
7. As space is the separator for parameters, strings containing a space can be given by
   using the ". A string also allowing " is currently not supported.

config2 1 %10 $ff "this is a string with spaces"

In this example config2 will be converted to a hash value and stored in parameter_list[0].
1 will be stored in parameter_list[1]
2 will be stored in parameter_list[2]
255 will be stored in parameter_list[3]
and the address of the first t will be stored in parameter_list[4] and the last " will be
replaced by a 0.

===== Some additional ideas ======
This object is called ConfigReader, but it can be used in other ways. Of course you can
read a config file at startup, where the program finds the serial interface settings ..
for example ... or the screen color ... whatever.

But you could also have several files containing data that you want to have in a readable
format because it's usually edited by a person or for nationalisation of your program.
For example:
File lang_e.txt
---------------
SplashScreenMessage "Welcome to blabla"
Error1 "File not found"
...

File land_de.txt
----------------
SplashScreenMessage "Willkommen bei blabla"
Error1 "Datei nicht gefunden"
...

graph.txt
---------
xAxis 100
yAxis 100
Bar 0 10 15 18 23 18 11 9 2 0

Another nice thing would be to use it for a script language.

DrawRec.sps
-----------
setCol 10 255 80

setPos 100 100
lineTo 150 100
lineTo 150 150
lineTo 100 150
lineTo 100 100
  
}}
con
  RET_LOAD_NEXT = 1
  RET_PAR_FOUND = 2
  RET_DONE      = 3

var
  word buf_adr, par_adr, buf_size, par_size
  word buf_fill, aofs, badr, rd, p_state

' This is for telling the object where to find the needed buffer and parameter list and
' their size.    
pub init( buffer_array, buffer_size, param_array, param_size )
  ' simply store the addresses for later usage 
  badr := buf_adr := buffer_array
  buf_size:= buffer_size
  par_adr := param_array
  par_size:= param_size

  ' initialize some variables
  p_state := buf_fill := aofs := 0
  rd:=512
  
' This is the function doing the whole job. If you call it after loading the next bunch
' of bytes, you'd pass the number of bytes read (even if it's 0). If you call it after a
' config line has been successfully parsed, you call it with 0.
' The return values low byte (byte 0) will always contain one of the RET_* constants
' for RET_LOAD_NEXT byte 1 and byte 2 contain the address where to load the data to
' for RET_PAR_FOUND byte 1 and byte 2 contain the start address of the parsed line,
'                   byte 3 contains the number of parameters found
pub parse( howmuch ) | ln, pc
  ' if RET_LOAD_NEXT was the last resutl, the user program now should have loaded the
  ' next bunch of bytes and tell how much have been loaded
  if p_state==0
    buf_fill+=rd:=howmuch
    'rd:=howmuch

  ' getLine first searches for linefeed. If no linefeed has been found, the return value
  ' will be negative or 0. 0 means that the end of the buffer has been reached.
  if (ln:=getLine( buf_adr+aofs ))>0
    'sz:=strsize( ln )
    ' calculate the adress offset for the next round
    aofs:= (ln-buf_adr)+strsize(ln)
   
    ' initialize all elements in the parameter list with 0 and then parse the line
    longfill(par_adr,0,par_size)
    pc := parseLine( ln )

    ' remember that we found parameters
    p_state := 1

    return RET_PAR_FOUND + (ln<<8) + (pc<<24)
   
  else
    ' negate the negative return value of getLine, which is the start address of the
    ' next line. (comments are already skipped here)
    ln:=-ln

    ' if we did not get 512 bytes with the last read, the end of the file has been
    ' reached and we're done
    if rd==512
      ' move the unprocessed part of the buffer to the beginning of the buffer
      bytemove( buf_adr, ln, 512 )
      ' remove the number of processed bytes from the number of bytes in the buffer
      buf_fill := buf_fill + buf_adr - ln ' + rd
      ' calculate the address for loading the next bunch
      badr := buf_adr + buf_fill
      ' next getLine has to search from the beginning
      aofs := 0
      ' next call of parse has to give the number of read bytes
      p_state := 0
      return RET_LOAD_NEXT + (badr<<8)
    else
      return RET_DONE
   
' This function has originally been used in CogOS and read the input of a keyboard.
' That's why you find those names.
pri parseLine( key_buffer ) | cmd_len, key_cnt, par_cnt, long_val, mode, sstart, i, j, mult
    ' parse the key_buffer for strings and numbers
    par_cnt:=1
    long_val:=0
    mode:=0
    ' this skips the first word which is the command
    key_cnt:=strsize( key_buffer )+1
    repeat i from 0 to key_cnt-1
      if byte[key_buffer][i]==$20
        cmd_len:=i-1
        i++
        quit
      else
        cmd_len:=i

    repeat
      ' mode 0 means that we have to find out what to parse next
      if mode==0
        ' if we find a 0 in mode 0 we are done with parsing
        ' and switch to mode 5 'end parsing'
        if byte[key_buffer][i]==0
          mode:=5
        else
          ' depending on the first character we find we can decide
          ' what to parse
          case byte[key_buffer][i]
            "$":       ' HEX-mode - set multiplicator for one digit for conversion
              mode:=4
              mult:=16
            "%":       ' Binary-mode
              mode:=3
              mult:=2
            "0".."9":  ' Decimal-mode
              mode:=2
              mult:=10
            other:     ' String-mode - store beginning of the string
              mode:=1
              sstart:=key_buffer+i

      ' current character is string terminator, so parameter has been parsed
      if mode<>0 and (byte[key_buffer][i]==" " or byte[key_buffer][i]==0)
        ' depending on the mode the parameter can be copied to the parameter list
        case mode
          1:     ' store the string address in par_list
            if byte[sstart]==34
              byte[key_buffer][i-1]:=0
              sstart++
            long[par_adr][par_cnt++] := sstart
            
          2..4:  ' store the number in par_list
            long[par_adr][par_cnt++]:=long_val
            long_val:=0
        ' set mode back to 'find next parameter'    
        mode:=0

        ' but don't overwrite memory that no longer belongs to the array
        if par_cnt == par_size
          mode := 5

      ' depending on mode the number-conversion has to be done
      case mode
        2..3:
          if byte[key_buffer][i]<>"%"
            long_val:=long_val*mult+byte[key_buffer][i]-$30
        4:
          if byte[key_buffer][i]<>"$"
            long_val:=long_val*mult
            if byte[key_buffer][i]<$3a
              long_val+=byte[key_buffer][i]-$30
            else
              long_val+=byte[key_buffer][i]-$57
                                
    while mode<>5 and ++i<key_cnt
    ' end of parsing

    ' generate a hash value from the command only, so we can have buildin commands
    long[par_adr][0]:=Hash(key_buffer, cmd_len)
    return par_cnt

pri Hash(string_ptr, len) : Result | x
 result := 0
 repeat len
   Result := (Result << 4) + byte[string_ptr++]
   x := Result & $F0_00_00_00
   if (x <> 0)
    Result := Result ^ (x >> 24)
   Result := result & !x

' getLine searches for linefeed characters and replaces those by zero. This means that
' the line can now be used as a string.
pri getLine( adr ) | anfang, i, state
      state := 0
      anfang := adr
      repeat i from adr to buf_adr+buf_fill-2
        ' found a comment character
        if byte[i]=="'"
          state:=1
        if i==anfang and ((byte[i]==0) or (byte[i]==$0a) or (byte[i]==$0d))
          anfang++
        else
          if byte[i]==$0d
            if i==anfang
              state:=1
            if state==0
              byte[i]:=0
              if byte[i+1]==$0a
                byte[i+1]:=0
                i++
              return anfang
            else
              anfang:=i+1
              state --
      if adr==anfang
        return 0
      else
        return -anfang
  