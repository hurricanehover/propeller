********************************************
*  Solar Calculator Object                 *
*  Author: Gregg Erickson                  *
*  December 2011                           *
*  See MIT License for Related Copyright   *
*  See end of file and objects for .       *
*  related copyrights and terms of use     *
*                                          *
*  This uses code from FullFloat32 &       *
*  equations and concepts from a           *
*  version of "Solar Energy Systems        *
*  Design" by W.B.Stine andR.W.Harrigan    *
*  (John Wiley and Sons,Inc. 1986)         *
*  retitled "Power From The Sun"           *
*  http://www.powerfromthesun.net/book.html*
********************************************
The solar object calculates a good approximation
of the position (altitude and azimuth) of the sun
at any time (local clock or solar) during the day
as well as events such as solar noon, sunrise,
sunset, twilight(astronomical, nautical, civil),
and daylength. Its 20+ methods also provide derived
values such as the equation of time, time meridians,
hour angle, day of the year, declination and angles
for a heliostate to reflect to a target are also provided.

Please note: The code is fully documented and is purposely less
compact than possible to allow the user to follow and/or
modify the formulas and code.


Object "Solar2.4" Interface:

PUB  Start
PUB  Stop
PUB  Rotation_Connecting_Rod(Radius, Shift)
PUB  Rotation_Fixed_Linear(Radius, Length, Distance)
PUB  Get_Elevation_Loss(D)
PUB  Get_Spreading_Loss(N, P, SizePtr)
PUB  Get_Cosine_Loss(Theta)
PUB  Helio_Altitude(AzPtr, AltPtr, ThetaPtr, FlightPtr, Az, Alt, N, E, Z)
PUB  Sun_Position(AzPtr, AltPtr, mo, dd, yy, hh, mm, ss, ds, lat, lng)
PUB  Get_Altitude(mo, dd, yy, hh, mm, ss, ds, lat, lng)
PUB  Get_Azimuth(mo, dd, yy, hh, mm, ss, ds, lat, lng)
PUB  Refraction(h)
PUB  Refraction_Main(h)
PUB  Refraction_Min(h)
PUB  Refraction_Neg(h)
PUB  Scout_Time(STime, Srise, Sset)
PUB  Extract_Hour(tm)
PUB  Extract_Minute(tm)
PUB  Solar_Time_From_AngleHour(Dy)
PUB  Hour_Angle_SolarTime(Ts) : Omega
PUB  Hour_Angle_Altitude(Delta, Lat, Alt)
PUB  Azimuth_Calc(Delta, Lat, Omega, Alpha)
PUB  Altitude_Calc(delta, Lat, Omega)
PUB  DayLight_Hours(WS)
PUB  Solar_Clock_Time(Hr, Lng, Mrdn, ET, D)
PUB  Local_Clock_Time(Hr, Lng, Mrdn, ET, D)
PUB  Declination_Degrees(N)
PUB  Meridian_Calc(lng)
PUB  Day_Number(Y, M, D)
PUB  Equation_Of_Time3(N)
PUB  Equation_Of_Time2(N)
PUB  Equation_Of_Time(N)

Program:   1,894 Longs
Variable:     58 Longs

__________
PUB  Start

Initiate Solar Object

_________
PUB  Stop

Stops Object

___________________________________________
PUB  Rotation_Connecting_Rod(Radius, Shift)

Returns the Angle of a Solar Receiver Operated by a Linear Actuator Via a Connecting Rod    
     Linear Actuator with Connecting Rod

                                @:Pivot Point
                               --:Plain of Axis Point(Movement Relative to This)
                               ^^:Face
                                •:Connecting Rod (Fixed Length)
                                *:Radial Arm (Output Angle Perpendicular to This)
                     @•         #:Linear Actuator (Variable Length)
                     *  •       R:Axis Point, Center of Rotation
                     *     •
                     R     --@=########=---
                     *
                     *
                 ^^^^^^^^^
     
____________________________________________________
PUB  Rotation_Fixed_Linear(Radius, Length, Distance)

Returns the Angle of a Solar Receiver Directly Operated by a Linear Actuator
 Linear Actuator Connected to Fixed Point

                              @:Pivot Point
                             --:Plain of Axis Point(No Movement Along This)
                             ^^:Face
                              *:Radial Arm (Output Angle Perpendicular to This)
                  @=#         #:Linear Actuator (Variable Length)
                  *   #       R:Axis Point, Center of Rotation
                  *     #
                  R    ---#=@---
                  *
                  *
              ^^^^^^^^^
     
__________________________
PUB  Get_Elevation_Loss(D)

Returns Loss in Elevation Due to Earth's Curvature
Returns a Floating Point Variable of the
Apparent Drop in Elevation Due to  Earth Curvature

______________________________________
PUB  Get_Spreading_Loss(N, P, SizePtr)

Returns the Size of a Reflected Image Based Upon Distance and Parallax
Returns Spreading Loss based upon Distance
   Relative Image Size

                  |: Resulting Image in B Units (Result)
                 --: Distance of Reflection in X Units (P)
                  [: Size of Image in Angular Degrees E (0.55 for sun)
                  
                  |
                  |    P    [
              Size|---------[N (r=a)
             (r=b)|         [
                  |
       
___________________________
PUB  Get_Cosine_Loss(Theta)

Returns the loss of a Helistat due to Cosine Effect
Return a Floating Point of Heliostat
Lost Due to Cosine Effect as a Percent

_________________________________________________________________________
PUB  Helio_Altitude(AzPtr, AltPtr, ThetaPtr, FlightPtr, Az, Alt, N, E, Z)

Returns Heading and Angle for a Mirror to Reflect the Sun to a Target
Calculates Azimuth and Altitude (angle) above the horizon
for a heliostat reflector to point to a collector point A

______________________________________________________________________
PUB  Sun_Position(AzPtr, AltPtr, mo, dd, yy, hh, mm, ss, ds, lat, lng)

Return Heading to Sun & Angle Above Horizon to a Memory Location Based Upon Time and Location  
Copies a Floating Point Altitude(angle) and Azimuth to variable
Designated by Pointers Using Date, Time and Location.

_______________________________________________________
PUB  Get_Altitude(mo, dd, yy, hh, mm, ss, ds, lat, lng)

Returns Angle of the Sun Above the Horizon Based Upon Time and Location  
Return Floating Point Altitude(angle) above the horizon

______________________________________________________
PUB  Get_Azimuth(mo, dd, yy, hh, mm, ss, ds, lat, lng)

Returns Heading To The Sun Based Upon Time and Location
Return Floating Point Azimuth(heading angle)

__________________
PUB  Refraction(h)

Returns Atmospheric Refraction/Bending (Selection of Equation)

_______________________
PUB  Refraction_Main(h)

Calculate Atmospheric Refraction (Altitude 0-85 Degrees)

______________________
PUB  Refraction_Min(h)

Calculate Atmospheric Refraction (Altitude 0.575-5.0 Degrees)

______________________
PUB  Refraction_Neg(h)

Calculate Atmospheric Refraction (Altitude <-0.575 Degrees)

___________________________________
PUB  Scout_Time(STime, Srise, Sset)

Returns Date Specific Time Converted to a Scale Relative to Noon, Sunrise and Sunset
This is a unique clock conversion for outdoor activities.
Return a floating point hour specific to day length and relative to sunrise and sunset.

_____________________
PUB  Extract_Hour(tm)

Returns an Integer Hour from a Floating Point Hour

_______________________
PUB  Extract_Minute(tm)

Returns an Integer Minute from a Floating Point Minute

__________________________________
PUB  Solar_Time_From_AngleHour(Dy)

Returns Solar Time from Hour Angle

_____________________________________
PUB  Hour_Angle_SolarTime(Ts) : Omega

Returns Hour Angle for Time Solar

_________________________________________
PUB  Hour_Angle_Altitude(Delta, Lat, Alt)

Returns Hour Angle Based Upon Altitude

___________________________________________
PUB  Azimuth_Calc(Delta, Lat, Omega, Alpha)

Returns Azimuth (Compass Direction) to Sun

_____________________________________
PUB  Altitude_Calc(delta, Lat, Omega)

Returns Azimuth (Compass Direction) to Sun

_______________________
PUB  DayLight_Hours(WS)

Returns Daylight Hours Based Upon Angle Hours in a Day

___________________________________________
PUB  Solar_Clock_Time(Hr, Lng, Mrdn, ET, D)

Returns Solar Time from Local Clock Time

___________________________________________
PUB  Local_Clock_Time(Hr, Lng, Mrdn, ET, D)

Returns Local Clock Time from Solar Time

___________________________
PUB  Declination_Degrees(N)

Returns Declination based upon Date

_______________________
PUB  Meridian_Calc(lng)

Returns Time Zone Meridian

________________________
PUB  Day_Number(Y, M, D)

Returns Day of Year from Date

_________________________
PUB  Equation_Of_Time3(N)

Returns Urschel Equation of Time

_________________________
PUB  Equation_Of_Time2(N)

Returns Whitman Equation of Time

________________________
PUB  Equation_Of_Time(N)

Returns Stein and Geyer Equation of Time

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