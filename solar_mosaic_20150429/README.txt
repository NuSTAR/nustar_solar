# NOTE: This is currently a straight copy of the 20141211 mosaic
# code and needs to be updated for the 20150429 data.

The code in this tree can be used to mosaic several NuSTAR
pointings.

Note that this combines events from both FPMs and that in the current
state it is not possible to determine from teh combined event file
whether an event came from FPMA or FPMB.


The scheme is the following:

- Combine the housekeeping files by simply merging together the HK
  FITS files.

- Generate a "CHU" output file, which tells you which combination of
  startrackers the spacecraft bus was using as any particular time.

- Read in and merge the heliocentric event files (e.g. those with a
  "sunpos" in the suffix) into a single monolithic event file.

  Notes: At this step the user can screen out "bad" pixels. Many of
  the NuSTAR filters have to be turned off when processing the solar
  data, so there are occasionally noisy pixels that can skew output
  images. The current version is set to screen out known bad pixels
  for the AR2192 (2014/11/01) observations, but this may need to be
  checked for other solar pointings.

  Notes II: At this stage a translation is added to the NuSTAR data
  set to account for the lack of absolute position recosntruction in
  the "SCIENCE_SC" mode where we use the spacecraft bus startrackers
  to project the events onto the sky. Again, the shift currently in
  the code was generated for the AR2912 (2014/11/01) data sets but may
  not be valid for subsequent solar pointings.

- "CHU"-dependent adjustment

  We know that the NuSTAR bus has small misalignments in its iternal
  attitude control system. This leads to small changes in the pointing
  when switching between different combinations of spacecraft bus startrackers
  (a.k.a "Camera Head Units" or "CHUs"). At this stage the user should
  check to see which combinations of CHUs are present (by putting
  break/stop statements in the code) and write out event files for
  each CHU combination (there is commented-out example code showing
  how to do this). These images produced by these files should be
  inspected (in ds9, for example). There are places called out in the
  code where additional translational shifts can be applied to
  different CHU combinations to make all of the images line up.

Dependencies:

- These scripts lean heavily on the astrolib. If you check out the
  nustar-idl git repo and make sure that these directories are in
  your IDL !PATH then things should work.


Inputs:

<mosaic_infile.txt>

This is a list of the observtions that you want to merge. The full
path must be given, like this:

~/lif_nustar/sol/data/20001003_Sol_14305_AR2192

Note that all sequence IDs in this directory that have been converted
to heliocentric coordinates will be merged.

Outputs:

<mosaic_eventfile.evt>

This is the merged output file. The prefix (before .evt) will be used
as the stem of the CHU and HK output files. This must end in ".evt".

Syntax:

./run_mosaic.sh mosaic_infile.txt mosaic.evt


The individual scripts should be fairly well commented in a "How to"
kind of way". But if you have question/comments/bugs to: bwgref@srl.caltech.edu






