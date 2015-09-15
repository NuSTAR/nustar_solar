PRO nustar_get_reference_image, infile, outdir = outdir, outfile = outfile, wave = wave
procname = 'nustar_get_reference_image'

IF ~keyword_set(wave) THEN wave = 94

IF ~file_test(infile) THEN message, procname+': File not found '+infile

; Make the outfile name:

outfile = outdir+'/'+file_basename(infile, '.evt')+'_ref_map_'+string(wave, format = '(i0)')+'.fits'
IF file_test(outfile) THEN BEGIN
   print, procname+': reference file exists '+outfile
   return
ENDIF

 ; Get the timestamp from the header
evthdr =headfits(infile)
tstart = fxpar(evthdr, 'TSTART')
ref_tstart = convert_nustar_time(tstart, /ut)
ref_tend = convert_nustar_time(tstart+60, /ut)
records = vso_search( ref_tstart, ref_tend, inst='AIA', wave=wave )     ; searches VSO
log = vso_get( records[0], filenames=ref_file )     ; downloads the first file found
fits2map, ref_file, ref_map    ; read in FITS file to a plot_map
spawn, 'mv '+ref_file+' '+outfile


END

