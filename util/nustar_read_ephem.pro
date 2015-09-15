function nustar_read_ephem, ephem_file


procname ='nustar_read_epehm'
IF ~file_test(ephem_file) THEN message, procname+': File not found '+ephem_file


  openr, lun, /get_lun, ephem_file
  

stub = {time:'string', raj2000:0., decj2000:0., np_ang:0.}
set = 0
fin = 0
while ~(eof(lun)) do begin
   input = 'string'
   readf, lun, input

   if set eq 0 then begin
      set = stregex(input, 'SOE', /boolean)
      if set then continue
   endif
   if set eq 0 then continue

  
   if fin eq 0 then begin
      fin = stregex(input, 'EOE', /boolean)
      if fin then break
   endif
   
   fields = strsplit(input, ' ', /extract)
   ; Re-order since JPL is now weird...
   date = strsplit(fields[0], '-', /extract)
   date = date[2]+'-'+date[1]+'-'+date[0]
   stub.time = date+' '+fields[1]
   stub.raj2000 = float(fields[2])
   stub.decj2000 = float(fields[3])
   stub.np_ang = float(fields[4])
   if n_elements(solar_ephem) eq 0 then begin
      solar_ephem = stub
   endif else begin
      solar_ephem = [solar_ephem, stub]
   endelse
endwhile

return, solar_ephem

end
