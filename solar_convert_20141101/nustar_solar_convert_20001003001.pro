

; Wrapper code for running the alignment with AIA
; 

; Pre-requisites: You must have already run the NuSTARDAS pipeline on the code once to produce the 
; SC_SCIENCE mode event data (mode 06).


; If your path doesn't have nustar_solar/util in it, add it here:
; Set your patht to the NuSTAR solar utility folder here:
nustar_path= '/disk/lif2/bwgref/git/nustar_solar/util/'
IF ~stregex(!path, 'nustar_solar/util', /boolean) THEN $
   !path = expand_path('+'+nustar_path)+':'+ $
           !path


; Set the location of the database of offsets that you'll use below.

SETENV, 'NUSTAR_PATH='+nustar_path
SETENV, 'NUSTAR_OFFSET_DB='+nustar_path+'/nustar_offset_db.sav'


; Compile code that you're going to use below

.compile $NUSTAR_PATH/nustar_split_chufiles
.compile $NUSTAR_PATH/nustar_convert_to_solar
.compile $NUSTAR_PATH/nustar_read_ephem
.compile $NUSTAR_PATH/nustar_correct_file

;;;;; Set the following path and file info to be appropriate to what
;;;;; you want to run.
indir = '/users/bwgref/lif_nustar/sol/data/20001003_Sol_14305_AR2192/20001003001/event_cl'
infile = 'nu20001003001A06_cl.evt'
ephem_file = '20141101_ephem.txt'
seqid = file_basename(file_dirname(indir))

; Defaults will work fine.
datdir = './dat'
gtidir = './gti'
evtdir = './evt'
mapdir = './maps'
figdir = './figs'

;;;;; You should not have to touch below here except to turn on/off
;;;;; different elements. You can run the script from an IDL prompt
;;;;; IDL> @nustar_solar_alignment.pro

; Make sure the output path exists.
file_mkdir, datdir
file_mkdir, gtidir
file_mkdir, evtdir
file_mkdir, mapdir
file_mkdir, figdir

; NB: infile is only used for reference here to generate the GTIs. All of
; the downstream work is done using bespoke event files and runs
; through BOTH FPMs (not just the one listed above).

; Check to make sure that you have the shell script to run the
; pipleine here

;; IF ~file_test('run_products_usrgti.sh') THEN spawn, 'cp '+nustar_path+'/run_products_usrgti.sh .'
;; nustar_chu2gti, indir+'/'+infile, outdir = gtidir


; Use nupipeline and split off each CHU combination into its own file

;; nustar_split_chufiles,indir, gtidir, evtdir


; Convert each of these files to heliocentric coordinates
; NB: nustar_convert_to_solar has internal checks to make sure that you're 
; only converting the files that you want to run.

;; evt_files = file_search(evtdir+'/nu*06_cl*chu*.evt')
;; FOR i = 0, n_elements(evt_files) -1 DO nustar_convert_to_solar, evt_files[i], ephem_file

; Correct the event files 

;; sunpos_files= file_search(evtdir+'/nu*sunpos.evt')
;; FOR i = 0, n_elements(sunpos_files) -1 DO nustar_correct_file, sunpos_files[i], datdir = datdir, outdir = evtdir


 
;end

    
