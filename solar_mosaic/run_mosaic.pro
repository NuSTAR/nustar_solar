pro run_mosaic

  infile = getenv('mosaic_infile')

  outfile = getenv('mosaic_outfile')
  if ~stregex(outfile, 'evt', /boolean) then begin
     print, 'Make sure the mosaic outfile ends in .evt'
     return
  endif
  
  
  openr, lun, /get_lun, infile
  while ~(eof(lun)) do begin
     input = 'string'
     readf, lun, input
     push, obslist, input
  endwhile

  print, 'Combining these observations: ', obslist

  read_chus, obslist
  read_hk, obslist
  combine_events, obslist
  adjust_chus
  
end

    
