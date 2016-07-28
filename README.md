# Nustar Solar Repo
Scripts for converting *NuSTAR* solar observations to usable heliocentric coordinates.

This branch uses python scripts rather than IDL scripts. This is currently work in progress.

Requirements:
  astopy
  numpy
  sunpy

We recommend using [Anaconda](https://www.continuum.io/downloads) for installation of astropy/numpy/everything else via conda.

See the [sunpy documenation](http://sunpy.org)how to install sunpy via conda.


# Contents: 

### setup_pointing:

Contains a jupyter notebook that demonstrates how to generate a pointing location and *NuSTAR* roll for a given observation. 

### solar_convert:

Work in progress. Empty. Will eventually contain the code to convert the solar observations into heliophysics coordinates.

### solar_analysis:

Empty. Will probably contain sunpy specific (or [SolarSoft](http://www.lmsal.com/solarsoft/) equivalent) code for making maps, interfacing with other observatories, etc.

### offset_files:

Directory tree that contains the offets for each of the sequence IDs and CHU combinations. This (may?) be updated as we get better alignment between NuSTAR and other missions. Note that the NuSTAR absolute reconstruction is usually only good to an arcminute or so for solar observations.




