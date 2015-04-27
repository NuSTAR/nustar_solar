pro parse_sun_center, infile

  openr, lun, /get_lun, infile

  while ~(eof(lun)) do begin
     input = 'string'
     readf, lun, input
     fields = strsplit(input, ' ', /extract)
     push, date, fields[0]
     push, time, fields[1]
     push, rapos, float(fields[2])
     push, decpos, float(fields[3])
     push, sunra, float(fields[4])
     push, sundec, float(fields[5])
     push, sunpa, float(fields[6])
  endwhile
     
  close, lun
  free_lun, lun

  
  

     
  delra = (rapos - sunra) * cos(decpos*!dtor); degrees   
  deldec = decpos - sundec  ; degrees
  sunpa *= !dtor

                                ; Celestial:
  
  
  x = delra * cos(sunpa) - deldec*sin(sunpa)
  y = delra * sin(sunpa) + deldec * cos(sunpa)

  dr = sqrt(x^2. + y^2.) * 3600.
  x *= 3600.
  y *= 3600.
  for i = 0, n_elements(rapos) - 1 do begin
     print, date[i], ' ', time[i], x[i], y[i]
  endfor
  
  


  stop

  end

  
