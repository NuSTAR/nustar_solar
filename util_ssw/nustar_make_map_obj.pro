PRO nustar_make_map_obj, evtfile, outdir, $
                         erange = erange

; erange has optional inputs [elow, ehigh] with elow and ehigh given
; in keV.

procname = 'nustar_make_map_obj'


f = file_info(evtfile)
if ~f.exists then message, procname+': File not found' + evtfile

; Construct output filename:
outname = file_basename(evtfile, '.evt')+'_map.fits'

IF ~keyword_set(erange) THEN erange = [3., 20.]

evt = mrdfits(evtfile, 'EVENTS', evthdr, /silent)

exposure = fxpar(evthdr, 'EXPOSURE')
ontime = fxpar(evthdr, 'ONTIME')
print, evtfile
print, 'Seconds of exposure: ', exposure
print, 'On target time: ', ontime

;; Filtering is done here:
pilow = (erange[0] - 1.6) / 0.04
pihigh = (erange[1] - 1.60) /  0.04
good_events = where(evt.grade EQ 0 AND evt.pi GT pilow AND evt.pi LT pihigh)
evt = (temporary(evt))[good_events]

; Get the astrometric info from the FITS headers

ttype = where(stregex(evthdr, "TTYPE", /boolean))
xt = where(stregex(evthdr[ttype], 'X', /boolean))
xpos = (strsplit( (strsplit(evthdr[ttype[max(xt)]], ' ', /extract))[0], 'E', /extract))[1]
npix = sxpar(evthdr, 'TLMAX'+xpos)
pix_size = abs(sxpar(evthdr,'TCDLT'+xpos))

; Set heliocenter to (0, 0)
xc = 0 & yc = 0
centerx = round(xc / pix_size) + npix * 0.5
centery = round(yc / pix_size) + npix * 0.5

pixinds = evt.x + evt.y * npix
im_hist = histogram(pixinds, min = 0, max = npix*npix-1, binsize = 1)
im = reform(im_hist, npix, npix) / ( float(exposure) / float(ontime))


pxs=pix_size

t0 =anytim(min(evt.time)+anytim('01-Jan-2010'),/yoh,/trunc)
 
; For some reason my map2fits.pro complains about no L0,B0 or Rsun if not provided
ang = pb0r(t0,/arcsec,l0=l0)

dt = max(evt.time) - min(evt.time)
ns_map = make_map(im,$
                  dx = pix_size, dy = pix_size, $
                  xc = 0., yc = 0., $
                  time = t0,dur=dt,$
                  l0=l0,b0=ang[1],rsun=ang[2])


map2fits,ns_map, outdir+'/'+outname


END


