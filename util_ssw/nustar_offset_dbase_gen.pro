PRO nustar_offset_dbase_gen, list

; Adds/appends offsets to the databse of pointings along with some
; useful information.

; Get the database:
dbase_file = getenv('NUSTAR_OFFSET_DB')

stub = {seqid:'string', $
        chu:'string', $
        fpm:'string', $
        xoff:0d, yoff:0d, $
        date:'string', $
        ref_file:'string'}
          
;; openu, lun, /get_lun, dbase_file
;; Column 1: Sequence ID (e.g. 20110002001)
;; Column 2: CHU Combination (either 1, 4, 9, 5, 10, 13, OR 14)
;; Column 3: X Offset (heliocentric, +X = East = Left)
;; Column 4: Y Offset (heliocentric, +Y = North = Up)
;; Column 5: Date (Useful, but NOT required).

FOR i = 0, n_elements(list) -1  DO BEGIN
   stub.chu = (strsplit(list[i], '_', /extract))[2]
   stub.seqid= strmid(list[i], 2+strpos(list[i], 'nu'), 11)
   fpm = strmid(list[i], 13+strpos(list[i], 'nu'), 1)
   restore, list[i]
   stub.xoff = shift[0]
   stub.yoff = shift[1]
   stub.fpm = 'FPM'+fpm
   
   hdr = headfits(map_file)
   stub.date = anytim(fxpar(hdr, 'DATE-OBS'), /ccsds)
   stub.ref_file = ref_file
   print, stub
   push, additions, stub
ENDFOR


IF file_test(dbase_file) THEN BEGIN
   restore, dbase_file
   
   ; Loop over the additions and see if they alraedy exist:
   use = fltarr(n_elements(additions)) +1
   FOR i = 0, n_elements(additions) - 1 DO BEGIN
      FOR j=0, n_elements(nustar_offset_dbase) - 1 DO begin 
         IF strmatch(additions[i].seqid, nustar_offset_dbase[j].seqid) EQ 1 AND $
            strmatch(additions[i].chu, nustar_offset_dbase[j].chu) EQ 1 AND $
            strmatch(additions[i].fpm, nustar_offset_dbase[j].fpm) EQ 1 AND $
            use[i] EQ 1 THEN begin
            nustar_offset_dbase[j] = additions[i] 
            use[i] = 0
         ENDIF
      ENDFOR
      IF use[i] EQ 1 THEN push, nustar_offset_dbase, additions[i] 
   ENDFOR

ENDIF ELSE BEGIN
   nustar_offset_dbase = additions
ENDELSE

save, nustar_offset_dbase, file = dbase_file

dbase_text_file = file_dirname(dbase_file)+'/'+file_basename(dbase_file, '.sav')+'.txt'
print, dbase_text_file
openw, lun, /get_lun,dbase_text_file
 
FOR  i =0, n_elements(nustar_offset_dbase) -1 DO BEGIN
  
   outstring = nustar_offset_dbase[i].seqid+' '+nustar_offset_dbase[i].fpm+' '+nustar_offset_dbase[i].chu+' '+string(nustar_offset_dbase[i].xoff, format = '(d12.2)')+$
               string(nustar_offset_dbase[i].yoff, format = '(d12.2)')+'         '+nustar_offset_dbase[i].date
   printf, lun, outstring

endfor
close, lun
free_lun, lun

;   mos = strmid(list[i], 3+strpos(list[i], 'chu'), 2)
;   print, strsplit(list[i], '_', /extract)
;   print, list[i], mos



end
