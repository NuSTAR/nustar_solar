# nustar_solar
Scripts for converting NuSTAR solar observations to usable heliocentric coordinates.

Note that most of the scripts in here are dependent on both the nustar-idl repo's, the AstroLib, and (occasionally) the Coyote libraries.

Please clone the nustar-idl library here:  https://github.com/NuSTAR/nustar-idl and follow all instructions for cloning the AstroLib and Coyote repos before continuing.

Contents: 

setup_pointing:

Sub-directories contain scripts that were used to determine the NuSTAR
pointing to track the Sun. Code is relatively straight forward to
parse, but is mostly offered without additional README files since
only super-pro users (BG and KKM) will probably use it.

solar_alignment

This directories contain the scripts needed to determine the
alignment between NuSTAR and the Sun. There is a more complete README
file inside of each one of these directories that describes how things
work and there are several "How To" IDL scripts that show how things
work.

Intended mostly for pro users (BG, LG, IGH, AM), as this requires
SSWIDL to run.

solar_convert:

This directories should be usable with "vanilla" IDL, the AstroLib,
Coyote Graphics Library, and nustar-idl.

offset_files:

Directory tree that contains the offets for each of the sequence IDs
and CHU combinations. Produced by the code in solar_alignment.



