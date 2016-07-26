pro parse_ephem

  infile = '20160726_ephem.txt'
  openr, lun, infile, /get_lun
  stub = {jd:double(0), ra:0., dec:0., pa:0., rad:0}
  set = 0
  while ~eof(lun) do begin
     input = 'string'
     readf, lun, input
     IF stregex(input, 'SOE', /boolean) THEN BEGIN
        set = 1
        CONTINUE
     ENDIF
     IF stregex(input, 'EOE', /boolean) THEN BREAK


     IF set EQ 0 THEN CONTINUE



     fields = strsplit(input, ' ', /extract)
     IF n_elements(fields) NE 7 THEN continue  

     stub.jd = double(fields[2])
     
     stub.ra = float(fields[3])
     stub.dec = float(fields[4])
     stub.pa = float(fields[5])
     stub.rad = float(fields[6])
     push, ephem, stub
  endwhile

  save, ephem, file = 'sun_ephemeris.sav'
end
