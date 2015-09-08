The code in this tree can be used to convert from "standard" SKY
coordinates to heliocentric coordinates.

Things are set up specifically to convert the AR2192 data set.

The scheme is the following:

- Read in th ephemeris from an ASCII file (included for AR2912) to
  determine the solar position/NP angle as a function of time.

- Read in a cleaned event file from the data directory.

- Interpolate the solar position onto the event times.

- Compute the helocentric offset.

- Rotate the coordiates to a "solar north == up, west == left"
  reference system (this may need to be tweaked, depending on whether
  or not you want to overlay with AIA data).

- Write out a standard FITS file that can be used with ds9 / xselect /
  xmimage / xronos /  etc for making images, spectra, and lightcurves.

Dependencies:

- These scripts lean heavily on the astrolib and on some
  time-conversion scripts used to translate the NuSTAR epoch times
  into UT time and vice versa. If you check out the nustar-idl git
  repo and make sure that these directories are in your IDL !PATH then
  things should work.

Syntax:

./convert_to_solar.sh FULL/PATH/TO/event_cl/nuOBSID[A/B]06_cl.evt

Output:

The output file is placed in the same tree as the input file, with a
"sunpos" suffix. For the above call, the output file is located here:

FULL/PATH/TO/event_cl/nuOBSID[A/B]06_cl_sunpos.evt



Question/comments/bugs to: bwgref@srl.caltech.edu






