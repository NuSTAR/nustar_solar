pro convert_to_solar

forward_function read_ephem

evtfile = getenv('convert_to_solar_file')

f = file_info(evtfile)
if ~f.exists then message, 'File not found!'

outpath = file_dirname(evtfile)
outfile = outpath+'/'+file_basename(evtfile, '.evt')+'_sunpos.evt'

evt=mrdfits(evtfile,1,evth)

   ; Find the vals associated with X and Y
ttype = where(stregex(evth, "TTYPE", /boolean))
xt = where(stregex(evth[ttype], 'X', /boolean))
yt = where(stregex(evth[ttype], 'Y', /boolean))

   ; Converted X/Y is always last in the header:
   ; Parse out the position:
xpos = (strsplit( (strsplit(evth[ttype[max(xt)]], ' ', /extract))[0], 'E', /extract))[1]
ypos = (strsplit( (strsplit(evth[ttype[max(yt)]], ' ', /extract))[0], 'E', /extract))[1]

 ; Grab astrometry header keywords:
ra0 = sxpar(evth,'TCRVL'+xpos)     ; should match TCRVL13 which has lower precision
dec0 = sxpar(evth,'TCRVL'+ypos)    ; should match TCRVL14 which has lower precision
x0 = sxpar(evth,'TCRPX'+xpos)      ; x ref pixel in same axes as x, y
y0 = sxpar(evth,'TCRPX'+ypos)      ; y ref pixel
delx = sxpar(evth,'TCDLT'+xpos)    ; pixel size in degree
dely = sxpar(evth,'TCDLT'+ypos)    ; pixel size in degree

; Convert to RA/DEC
yd = dec0 + (evt.y - y0)*dely
xr = ra0 + (evt.x - x0)*delx/cos(dec0/180.0d0*!dpi) ; imperfect correction for cos(dec) for quick work



; Convert event files to MJD:
;   tt = evt.time mod 86400.0d0  ; seconds of current day
;   tmjd = 55197.0d0 + evt.time/86400.0d0
tmjd = convert_nustar_time(evt.time, /mjd)


ephem = read_ephem('ar2222_ephem.txt')


nustar_time = convert_nustar_time(ephem.time, /from_ut)


ra = ephem.raj2000
dec = ephem.decj2000
pa = ephem.np_ang

; Interpolate onto the event times:
xs = interpol(ra, nustar_time, evt.time)
ys = interpol(dec, nustar_time, evt.time)
p0 = interpol(pa, nustar_time, evt.time)
p0 = p0 * !dtor ; convert to radians for below.


; RA, dec offsets of photons from Sun center in arcsec
dx = -(xr - xs)*3600.0d0 ; 
dy =  (yd - ys)*3600.0d0

; Rotate to NP
dxs = dx * cos(p0) + dy * sin(p0)
dys = dy * cos(p0) - dx * sin(p0)

                                ; Apply fiducial offsets in Solar frame (N is Up, West is right)
; NB: This is determined by hand.
dxs += 50.                      ; 50" to the West
dys += 15.                      ; 15" to the North

   ; Convert back to degrees:

   ; change to 0-3000 pixels:
maxX = 3000
maxY = 3000
x0 = maxX / 2.
y0 = maxY / 2.
dely = dely * 3600. ; convert to arcsecond scales for AIA comparisons
delx = delx * 3600. ; switch from West = left to West = right



evt.x = (dxs / delx) + x0 
evt.y = (dys / dely) + y0


; Adjust astrometry headers
fxaddpar, evth, 'TCRVL'+xpos, '0.0'
fxaddpar, evth, 'TCRVL'+ypos, '0.0'
fxaddpar, evth, 'TCDLT'+xpos, delx ; minus to account for left/right switch for solar vs astro
fxaddpar, evth, 'TCDLT'+ypos, dely
fxaddpar, evth, 'TLMAX'+xpos, maxX
fxaddpar, evth, 'TLMAX'+ypos, maxY
fxaddpar, evth, 'TCRPX'+xpos, x0
fxaddpar, evth, 'TCRPX'+ypos, y0
mwrfits, evt, outfile, evth, /create

   

end



