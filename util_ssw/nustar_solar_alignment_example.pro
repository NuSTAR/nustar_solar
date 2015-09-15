

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

; Compile code that you're going to use below
.run nustar_split_chufiles
.run nustar_convert_to_solar
.run nustar_read_ephem
.run nustar_make_map_obj
.run gauss_smooth
.run nustar_plot_map
.run nustar_get_reference_image
.run nustar_align_tile
.run nustar_correct_file
.run nustar_combine_maps

;;;;; Set the following path and file info to be appropriate to what
;;;;; you want to run.
indir = '/users/bwgref/lif_nustar/sol/data/20001003_Sol_14305_AR2192/20001003001/event_cl'
infile = 'nu20001003001A06_cl.evt'
ephem_file = '20141101_ephem.txt'

seqid = '20001003001'
; Defaults will work fine.
datdir = './dat'
gtidir = './gti'
evtdir = './evt'
mapdir = './maps'
figdir = './figs'
;;;;; You should not have to touch below here.

; Make sure the output path exists.
file_mkdir, datdir
file_mkdir, gtidir
file_mkdir, evtdir
file_mkdir, mapdir
file_mkdir, figdir

; Make the GTIs for each CHU combination
; Syntax:
;nustar_chu2gti, infile, $
;                       outdir=outdir, show = show, ps=ps

; NB: infile is only used for reference here to generate the GTIs. All of
; the downstream work is done using bespoke event files.

;nustar_chu2gti, indir+'/'+infile, outdir = gtidir


; Use nupipeline and split off each CHU combination into its own file
;nustar_split_chufiles,indir, gtidir, evtdir


; Convert each of these files to heliocentric coordinates
; NB: nustar_convert_to_solar has internal checks to make sure that you're 
; only converting the files that you want to run.
;evt_files = file_search(evtdir+'/nu*06_cl*chu*.evt')
;FOR i = 0, n_elements(evt_files) -1 DO nustar_convert_to_solar, evt_files[i], ephem_file


; End of non-SSW branch

; Make a map object for each of the files
;sunpos_files= file_search(evtdir+'/nu*sunpos.evt')
;FOR i = 0, n_elements(sunpos_files) -1 DO nustar_make_map_obj, sunpos_files[i], mapdir 


; Get a reference image and make a map, if you haven't already
;nustar_get_reference_image, indir+'/'+infile, outdir = datdir, $
;                            outfile = ref_file


; Align each tile to the reference tile
;map_files= file_search(mapdir+'/nu*map.fits')
;FOR i = 0, n_elements(map_files) -1 DO nustar_align_tile, ref_file, map_files[i],datdir = datdir, figdir = figdir


; Correct the event files (NO SSW needed!!!!)
;sunpos_files= file_search(evtdir+'/nu*sunpos.evt')
;FOR i = 0, n_elements(sunpos_files) -1 DO nustar_correct_file, sunpos_files[i], datdir = datdir, outdir = evtdir




; Make a map object for each of the files
;sunpos_files= file_search(evtdir+'/nu*sunpos_corr.evt')
;FOR i = 0, n_elements(sunpos_files) -1 DO nustar_make_map_obj, sunpos_files[i], mapdir

; Combine the maps:
;; mapfiles = file_search(mapdir+'/nu*corr_map.fits')
;; combine_file = mapdir+'/nu'+seqid+'_combined_corr_map.fits'
;; nustar_combine_maps, mapfiles, outfile = combine_file
 
;map_files= file_search(mapdir+'/nu*combined_corr_map.fits')
;FOR i = 0, n_elements(map_files) -1 DO nustar_plot_map, map_files[i], outdir=figdir

 
;end

    
