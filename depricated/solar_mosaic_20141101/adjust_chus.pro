pro adjust_chus

  ; Get all of the events and housekeeping data:
  outfile = getenv('mosaic_outfile')
  prefix = file_dirname(outfile)+'/'+file_basename(outfile, '.evt')

  all_evt = mrdfits(outfile, 1, evth)

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

;; chu_list = [1, 4, 9, 5, 10, 13, 14]
;; FOR i = 0, n_elements(chu_list) - 1 DO BEGIN
;;    inrange = where(chu_comb EQ chu_list[i], nfound)

;;    IF nfound GT 0 THEN begin
;;       this_evt = all_evt[inrange]
;;       thisout = file_basename(outfile,'.evt')+'_chuselect'+string(chu_list[i], format = '(i0)')+'.evt'
;;       mwrfits, this_evt, thisout, evth, /create   
;;    ENDIF 

;; ENDFOR


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
