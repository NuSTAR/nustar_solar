function solar_mosaic_hk
; Description: Code for making the CHU masks for the solar mosaics and
; fetching the housekeeping data (so that one can easily do livetime
; corrections later).
;
; Last update: 2014/12/01 (BG)
; Added readme text.
;
; Previous Updates:
; 2014/11/28
; Added code to fetch the CHU combinations.
; 2014/11/27
; Creation. Purpose is to to make an output FITS housekeeping file for
; use in making livetime corrections to movies.
;
; Notes:
; Mask formalism based on code by KKM.
;
; You may have to adjust the code that searches the paths for the
; relevant files.
; 
; Note that the HK files are dumped into a FITS file (for later use
; with movie-making scripts) while the CHU data are saved in an IDL
; .sav file).
;
; Also note that this code is meant to be used to generate a single
; combined file for various mosaics. Below I've justed included
; the data from orbit 2+3. You can adjust obs_list as necessary. Two
; examples are below.

obs_list = ['20001003_Sol_14305_AR2192']
prefix = 'solar_mosaic_orbit23'

obs_list = ['20012001_Sol_14305_AR2192_1', '20012002_Sol_14305_AR2192_2', $
            '20012003_Sol_14305_AR2192_3','20012004_Sol_14305_AR2192_4']
 prefix = 'solar_mosaic_orbit4'

out_hkfile = prefix+'.hk'
out_chufile = prefix+'_chu.sav'


for obs = 0, n_elements(obs_list) -1 do begin
   datpath = file_search(obs_list[obs]+'/*', /test_dir)

   hkfiles = file_search(datpath+'/hk/', '*fpm.hk')
   for i = 0, n_elements(hkfiles) -1 do begin
      hkdat = mrdfits(hkfiles[i], 1, hkhdr) ; 1 Hz housekeeping:
      push, all_hk, hkdat
   endfor

   chufile = file_search(datpath+'/hk/', '*chu123.fits')
   f = file_info(chufile)
   if ~f.exists then stop
   
   for chunum= 1, 3 do begin
      chu = mrdfits(chufile, chunum)
      maxres = 20 ;; [arcsec] maximum solution residual
      qind=1 ; From KKM code...
 
      if chunum eq 1 then begin
         mask = (chu.valid EQ 1 AND $          ;; Valid solution from CHU
               chu.residual LT maxres AND $  ;; CHU solution has low residuals
               chu.starsfail LT chu.objects AND $ ;; Tracking enough objects
               chu.(qind)(3) NE 1)*chunum^2       ;; Not the "default" solution
      endif else begin
         mask += (chu.valid EQ 1 AND $            ;; Valid solution from CHU
                  chu.residual LT maxres AND $    ;; CHU solution has low residuals
                  chu.starsfail LT chu.objects AND $ ;; Tracking enough objects
                  chu.(qind)(3) NE 1)*chunum^2       ;; Not the "default" solution
      endelse
   endfor

   chu_stub = {time:0.d, chu:0}
   chu_str = replicate(chu_stub, n_elements(chu))
   chu_str.time = chu.time
   chu_str.chu = mask


   ;; The mask combinations mean:
    ;; mask = 1, chu1 only                                                                                                                                                                     
    ;; mask = 4, chu2 only                                                                                                                                                                     
    ;; mask = 9, chu3 only                                                                                                                                                                     
    ;; mask = 5, chu12                                                                                                                                                                         
    ;; mask = 10 chu13                                                                                                                                                                         
    ;; mask = 13 chu23  

    ;; mask = 14 chu123  

   push, all_chu, chu_str
   
endfor
mwrfits, all_hk, out_hkfile, hkhdr, /create   
save, all_chu, file = out_chufile

end
