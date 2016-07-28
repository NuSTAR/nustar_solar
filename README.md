# Nustar Solar Repo
Scripts for converting *NuSTAR* solar observations to usable heliocentric coordinates.

This branch uses python scripts rather than IDL scripts. This is currently work in progress.

Requirements:
  astopy
  numpy
  sunpy

Reccomend using [conda](https://www.continuum.io/downloads) for installation of astropy/numpy.

See the sunpy documentation on how to install sunpy via conda.



Contents: 

setup_pointing:

Contains a jupyter notebook that demonstrates how to generate a pointing location and *NuSTAR* roll for a given observation. 

solar_convert:



offset_files:

Directory tree that contains the offets for each of the sequence IDs
and CHU combinations. Produced by the code in solar_alignment.



