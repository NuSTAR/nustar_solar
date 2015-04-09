pro adjust_chus

  ; Get all of the events and housekeeping data:
  outfile = getenv('mosaic_outfile')
  prefix = file_dirname(outfile)+'/'+file_basename(outfile, '.evt')

  chufile = prefix+'_chu.sav'
  corrfile = prefix+'_corr.evt'

  f = file_info(chufile)
  if ~f.exists then stop
; Restore all_chu from the CHU data
  restore, chufile
; Interpolate the times to the get the CHU combination:
  chu_comb = round(interpol(all_chu.chu, all_chu.time, all_evt.time))

; Add other event screening here (energy, etc)


; This is also where you can adjust each of the CHU's. Note
; that you need to look at the IDL save file above to figure out which
; combinations you have.

; Uncomment the lines below and add others for whatever chu
; combination you have if you want to use ds9 to look for alignment
; issues.
  
;; inrange = where(chu_comb eq 13)
;; this_evt = all_evt[inrange]
;; outfile = file_basename(infile, '.evt')+'_chuselect13.evt'
;; mwrfits, this_evt, outfile, evth, /create   
;inrange = where(chu_comb eq 14)
;this_evt = all_evt[inrange]
;; outfile = file_basename(infile, '.evt')+'_chuselect123.evt'
;; mwrfits, this_evt, outfile, evth, /create   


; Here's an example (for AR2912) of how to apply an adjustment
; to a particular CHU combination.
inrange = where(chu_comb eq 10)
all_evt[inrange].x += 33
all_evt[inrange].y += 26
;; this_evt = all_evt[inrange]
;; outfile = file_basename(infile, '.evt')+'_chuselect23.evt'
;; mwrfits, this_evt, outfile, evth, /create   


; Once you're done, write everything to the output file.
mwrfits, all_evt, corrfile, evth, /create   



end
