pro read_chus, obs_list

  outfile = getenv('mosaic_outfile')
  prefix = file_dirname(outfile)+'/'+file_basename(outfile, '.evt')
  out_chufile = prefix+'_chu.sav'
  
  for obs = 0, n_elements(obs_list) -1 do begin
     datpath = file_search(obs_list[obs]+'/*', /test_dir)

     chufile = file_search(datpath+'/hk/', '*chu123.fits')

     for chunum= 1, 3 do begin
        chu = mrdfits(chufile, chunum)
        maxres = 20  ;; [arcsec] maximum solution residual
        qind=1       ; From KKM code...
        
        if chunum eq 1 then begin
        mask = (chu.valid EQ 1 AND $                     ;; Valid solution from CHU
                chu.residual LT maxres AND $             ;; CHU solution has low residuals
                chu.starsfail LT chu.objects AND $       ;; Tracking enough objects
                chu.(qind)(3) NE 1)*chunum^2             ;; Not the "default" solution
     endif else begin
        mask += (chu.valid EQ 1 AND $                     ;; Valid solution from CHU
                       chu.residual LT maxres AND $     ;; CHU solution has low residuals
                       chu.starsfail LT chu.objects AND $ ;; Tracking enough objects
                       chu.(qind)(3) NE 1)*chunum^2       ;; Not the "default" solution
           endelse
        endfor
        chu_stub = {time:0.d, chu:0}
        chu_str = replicate(chu_stub, n_elements(chu))
        chu_str.time = chu.time
        chu_str.chu = mask
        ;; The mask combinations mean:
        ;; mask = 1, chu1                                                                     
        ;; mask = 4, chu2                                                                     
        ;; mask = 9, chu3                                                                     
        ;; mask = 5, chu12
        ;; mask = 10 chu13
        ;; mask = 13 chu23  
        ;; mask = 14 chu123  
        
        push, all_chu, chu_str
     endfor
  
  save, all_chu, file = out_chufile
  return


end

  
