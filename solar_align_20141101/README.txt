The code in this tree can be used to convert NuSTAR files from RA/DEC
coordinates to heliocentric coordinates. As written, the code will
download a reference image (AIA 94A is hard coded for now, but this
may be made more fleixble later on) and perform a cross-correlation
between the NuSTAR image an the reference image.

A walk-through file is provided in this directory. It can be run using
the @file.pro formalism. I recommend doing it this way and
uncommenting out various steps as you make sure that they work.

Pre-requisite: You must already have the NuSTARDAS installed. There is
a wrapper script here that calls the pipeline in a "solar friendly"
way (turning off various filters to prevent a large fraction of real
events from getting vetoed in the software).

The alignment code here is intended for "pro" users (BG, LG, IGH, etc)
who will perform the alignment. Eventually there will be a databse
file distributed to all users that will contain the gold standard
offsets for each solar observation. 

A separate directory for just "conversion" is in the works and will
contain a similar walkthrough file that applies the chu-by-chu
offsets to the event files.


-----------------------------------------------------------------------

Dependencies:

- These scripts lean heavily on the astrolib, Coyote graphics library,
  the nustar-idl distribution, and the SSWIDL distribution for
  accessing the AIA data and making and manipulating map objects.

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

./evt

This directory will contain the products from running the pipeline
using nupipeline to split the event files based on the GTIs produced
by nustar_chu2gti.pro as well as the ancillary files.

./dat

Directory contains the reference image and will also contain IDL SAVE
files that will store the various offsets.

./maps

Direcotry contains the "map" objects produced here.

./figs

Directory contains output figures (especially the figures showing the
before/after the offset has been applied).

-----------------------------------------------------------------------

This code is provided "As Is". If you find a bug, let me know at
bwgref@srl.caltech.edu






