

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

; And the ssw_util path
nustar_ssw_path= '/disk/lif2/bwgref/git/nustar_solar/util_ssw/'
IF ~stregex(!path, 'nustar_solar/util_ssw', /boolean) THEN $
   !path = expand_path('+'+nustar_ssw_path)+':'+ $
           !path

; Set the location of the database of offsets that you'll use below.

SETENV, 'NUSTAR_SSWPATH='+nustar_ssw_path
SETENV, 'NUSTAR_PATH='+nustar_path
SETENV, 'NUSTAR_OFFSET_DB='+nustar_path+'/nustar_offset_db.sav'


; Compile code that you're going to use below

.compile $NUSTAR_PATH/nustar_split_chufiles
.compile $NUSTAR_PATH/nustar_convert_to_solar
.compile $NUSTAR_PATH/nustar_read_ephem
.compile $NUSTAR_PATH/nustar_correct_file

.compile $NUSTAR_SSWPATH/nustar_make_map_obj
.compile $NUSTAR_SSWPATH/gauss_smooth
.compile $NUSTAR_SSWPATH/nustar_plot_map
.compile $NUSTAR_SSWPATH/nustar_get_reference_image
.compile $NUSTAR_SSWPATH/nustar_align_tile
.compile $NUSTAR_SSWPATH/nustar_combine_maps
.compile $NUSTAR_SSWPATH/nustar_make_submap

;;;;; Set the following path and file info to be appropriate to what
;;;;; you want to run.
indir = '/users/bwgref/lif_nustar/sol/data/20012004_Sol_14305_AR2192_4/20012004002/event_cl'
infile = 'nu20012004002A06_cl.evt'
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

;; IF ~file_test('run_pipe_usrgti.sh') THEN spawn, 'cp '+nustar_path+'/run_pipe_usrgti.sh .'
;; nustar_chu2gti, indir+'/'+infile, outdir = gtidir


; Use nupipeline and split off each CHU combination into its own file

;; nustar_split_chufiles,indir, gtidir, evtdir


; Convert each of these files to heliocentric coordinates
; NB: nustar_convert_to_solar has internal checks to make sure that you're 
; only converting the files that you want to run.

;; evt_files = file_search(evtdir+'/nu'+seqid+'*06_cl*chu*.evt')
;; FOR i = 0, n_elements(evt_files) -1 DO nustar_convert_to_solar, evt_files[i], ephem_file

; End of non-SSW branch

; Make a map object for each of the files

;; sunpos_files= file_search(evtdir+'/nu'+seqid+'*sunpos.evt')
;; FOR i = 0, n_elements(sunpos_files) -1 DO nustar_make_map_obj, sunpos_files[i], mapdir 


; Get a reference image and make a map, if you haven't already

nustar_get_reference_image, indir+'/'+infile, outdir = datdir, $
                            outfile = ref_file


; Align each tile to the reference tile
; This pointing doesn't have anything obvious to align to, so
; just a null offset:
map_files= file_search(mapdir+'/nu'+seqid+'*sunpos_map.fits')
FOR i = 0, n_elements(map_files) -1 DO nustar_align_tile, ref_file, map_files[i],datdir = datdir, figdir = figdir, shift_manual = [0, 0]

; Generate the database of offsets:
;; offset_files= file_search(datdir+'/nu*sunpos_offset.sav')
;; nustar_offset_dbase_gen, offset_files


; Correct the event files (NO SSW needed!!!!)

;; sunpos_files= file_search(evtdir+'/nu'+seqid+'*sunpos.evt')
;; FOR i = 0, n_elements(sunpos_files) -1 DO nustar_correct_file, sunpos_files[i], datdir = datdir, outdir = evtdir

; Make a map object for each of the files
;; sunpos_files= file_search(evtdir+'/nu'+seqid+'*sunpos_corr.evt')
;; FOR i = 0, n_elements(sunpos_files) -1 DO nustar_make_map_obj, sunpos_files[i], mapdir

; Combine the maps:

;; mapfiles = file_search(mapdir+'/nu*corr_map.fits')
;; combine_file = mapdir+'/nu'+seqid+'_combined_corr_map.fits'
;; nustar_combine_maps, mapfiles, outfile = combine_file


;; map_files= file_search(mapdir+'/nu*combined_corr_map.fits')
;; FOR i = 0, n_elements(map_files) -1 DO nustar_plot_map, map_files[i], outdir=figdir

 
;end

    
