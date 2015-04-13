pro read_hk, obs_list

    ; Get all of the events and housekeeping data:
  outfile = getenv('mosaic_outfile')
  prefix = file_dirname(outfile)+'/'+file_basename(outfile, '.evt')
  out_hkfile = prefix+'.hk'
  
  for obs = 0, n_elements(obs_list) -1 do begin
     datpath = file_search(obs_list[obs]+'/*', /test_dir)
     hkfiles = file_search(datpath+'/hk/', '*fpm.hk')
     for i = 0, n_elements(hkfiles) -1 do begin
        hkdat = mrdfits(hkfiles[i], 1, hkhdr) ; 1 Hz housekeeping:
        push, all_hk, hkdat
     endfor
  endfor
  mwrfits, all_hk, out_hkfile, hkhdr, /create   

end
