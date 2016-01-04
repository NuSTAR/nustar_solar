The code in this tree can be used to convert NuSTAR files from RA/DEC
coordinates to heliocentric coordinates.

A walk-through file is provided in this directory. It can be run using
the @file.pro formalism. I recommend doing it this way and
uncommenting out various steps as you make sure that they work.

Pre-requisite: You must already have the NuSTARDAS installed. There is
a wrapper script here that calls the pipeline in a "solar friendly"
way (turning off various filters to prevent a large fraction of real
events from getting vetoed in the software).

-----------------------------------------------------------------------

Dependencies:

- These scripts lean heavily on the astrolib, Coyote graphics library,
  the nustar-idl distribution. See the README file in the nustar-idl
  git for installation instructions for those repositories.

-----------------------------------------------------------------------

Inputs:

--- Event files ---

You need to have run the pipeline on the data at least once. In the
walkthrough scripts you will neeed to adjust various paths to yoru
files by hand.

--- Solar Ephemeris ---

You should go here to get the ephemeris:

http://ssd.jpl.nasa.gov/horizons.cgi

Ephemeris Type:
          Observer

Target Body:
       Sol (Sun)

Observer Location:
     Geocentric

Time Span:
     Set appropriately for your obsrevation. I recommend getting the
     entire day of your observation with a bit of time before/after.
     I also recommend getting a sample at least every five
     minutes. The code will interpolate this onto the actual event
     times, but you might as well get a decent cadence at the beginning.


Table Settings (the following should be checked):

    Astrometric RA/DEC (Field 1)
    North pole position angle and distance (Field 17)


With the following settings for the Optional observer-table settings:

     Date/time format: Calendar only (no Julian days).
     Time Digits: Fractional Seconds


You can either download the ephmeris directly from Horizons or copy
and paste it into a text file. Note that the parser assumes that you
copy the WHOLE ephemeris (not just the data) since it ignores the
header information in the ephemeris and searchs for the $SOE and $EOE
keywords in the file.

-----------------------------------------------------------------------

Outputs (default settings):

./gti

This directory will contain Good Time Interval (GTI) files that give
periods of time (in NuSTAR epoch seconds) when each combination of
startrackers is being used. The user should not ever need to look
into this directory. All of these GTIs are compatible with the
NuSTARDAS pipeline (nupipeline) and can be fed into the pipeline using
the "usrgtifile" keyword. An example shell script showing how this
works is included here.

./evt

This directory will contain the products from running the pipeline
using nupipeline to split the event files based on the GTIs produced
by nustar_chu2gti.pro as well as the ancillary files. These files will
have an identifier (e.g. "chu12") in the file name.

This directory will contain the first conversion to heliocentric
coordinates, which will have a filename ending in "sunpos.evt"

This directory will contain the final files which will have the
correction to heliocentric coordinates applied to them. They will have
a suffix of "sunpos_corr.evt".

Note:
The X/Y values in these FITS files are the X/Y offset values from
the heliocenter in arcseconds.

In this formalism:
 +X = West = "Right" in images.
 +Y = North = "Up" in images.

-----------------------------------------------------------------------

This code is provided "As Is". If you find a bug, let me know at
bwgref@srl.caltech.edu






