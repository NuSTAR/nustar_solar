; Generates a file tree of offset files (ROOT/SEQID/CHU/offset_FPMA[B].txt)
; where each file has the following columns:


;; Column 1: X Offset (heliocentric, +X = East = Left)
;; Column 2: Y Offset (heliocentric, +Y = North = Up)
;; Column 3: Sequence ID (e.g. 20110002001)
;; Column 4: CHU Combination
;; Column 5: FPM (FPMA or FPMB)
;; Column 6: Date of observation
;; Column 7: Path to reference image
;; Column 8: Path to NuSTAR image 
;; Column 9: Notes
  
;; The parser only cares about the first two columns, so the remaining
;; columns are relatively free form and are not required (but are
;; useful in that they are human-readable).

;; Note: Since the map generator code is part of SSW it mangles the
;; date string into some anytim format. So you MUST run this script
;; with the SSWIDL routine.


PRO nustar_offset_dbase_gen, $
   overwrite = overwrite





  db_root = '../offset_files'

;; Find the list of offset files from the solar_aligment/dat
;; directory:

  offset_files = file_search('./dat/*offset*sav')

  nfiles = n_elements(offset_files) 
  FOR i = 0, nfiles - 1 DO BEGIN
     


                                ; Parse relevant info out of the filename
     chu = (strsplit(offset_files[i], '_', /extract))[2]
     seqid= strmid(offset_files[i], 2+strpos(offset_files[i], 'nu'), 11)
     fpm = 'FPM'+strmid(offset_files[i], 13+strpos(offset_files[i], 'nu'), 1)    
                                ; Load the offset file
     restore, offset_files[i]
     xoff = string(-1*shift[0], format = '(i0)')
     yoff = string(-1*shift[1], format = '(i0)')
     
                                ; Get the date info out of the file header
     hdr = headfits(map_file)
     date = anytim(fxpar(hdr, 'DATE-OBS'), /ccsds)
     
     ; Check to see if this directory already exists:
     dirpath = db_root + '/'+seqid+'/'+chu

     file_mkdir, dirpath
     outfile = dirpath+'/offset_'+fpm+'.txt'
     openw, lun, /get_lun, outfile

     outstring = xoff+'  '+yoff+'  '+seqid+'  '+chu+'  '+fpm+'  '+date+'  '+ref_file+'  '+map_file
     printf, lun, outstring
     close, lun
     free_lun, lun

  ENDFOR


end
