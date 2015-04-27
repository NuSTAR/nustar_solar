pro parse_ephem

  infile = 'sun_ephemeris.txt'
  openr, lun, infile, /get_lun
  stub = {jd:double(0), ra:0., dec:0.}
  while ~eof(lun) do begin
     input = 'string'
     readf, lun, input
     fields = strsplit(input, ' ', /extract)
     stub.jd = double(fields[2])
     
     stub.ra = float(fields[4])
     stub.dec = float(fields[5])
     push, ephem, stub
  endwhile
  save, ephem, file = 'sun_ephemeris.sav'
end
