This directory contains the solar ephemeris that allows the code to conver from RA/Dec coordinates to heliocentric coordinates.

You should go here to get the ephemeris:

http://ssd.jpl.nasa.gov/horizons.cgi

Ephemeris Type:
          Observer

Target Body:
       Sol (Sun)

Observer Location:
     Geocentric

Time Span:
     Set appropriately for your obsrevation. We recommend getting the
     entire day of your observation with a bit of time before/after.
     We also recommend getting a sample at least every five
     minutes. The code will interpolate this onto the actual event
     times, but you might as well get a decent cadence at the beginning.


Table Settings (the following should be checked):

    Astrometric RA/DEC (Field 1)
    North pole position angle and distance (Field 17)


With the following settings for the Optional observer-table settings:

     Date/time format: Both (Calendar date as well as Julian days).
     Time Digits: Fractional Seconds

You can either download the ephmeris directly from Horizons or copy
and paste it into a text file. Note that the parser assumes that you
copy the WHOLE ephemeris (not just the data) since it ignores the
header information in the ephemeris and searchs for the $SOE and $EOE
keywords in the file.

-----------------------------------------------------------------------

This code is provided "As Is". If you find a bug, let me know at
bwgref@srl.caltech.edu






