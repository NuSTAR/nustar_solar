PRO nustar_correct_file, infile, datdir = datdir, outdir = outdir
procname = 'nustar_correct_file

IF ~keyword_set(datdir) THEN datdir = './dat'
IF ~keyword_set(outdir) THEN outdir = './evt'  
IF ~file_test(infile) THEN message, procname+': File not found'+infile

savfile = datdir+'/'+file_basename(infile, '.evt')+'_offset.sav'
IF ~file_test(savfile) THEN message, procname+': File not found'+savfile

outfile = outdir+'/'+file_basename(infile, '.evt')+'_corr.evt'

data = mrdfits(infile, 'EVENTS', evthdr, /silent)
gti = mrdfits(infile, 'GTI', gtihdr, /silent)

; Get the astrometric information from the header
ttype = where(stregex(evthdr, "TTYPE", /boolean))
xt = where(stregex(evthdr[ttype], 'X', /boolean))
xpos = (strsplit( (strsplit(evthdr[ttype[max(xt)]], ' ', /extract))[0], 'E', /extract))[1]
npix = sxpar(evthdr, 'TLMAX'+xpos)
pix_size = abs(sxpar(evthdr,'TCDLT'+xpos)) ; Assume that this is given in arcseconds for the corrected files.

restore, savfile
data.x += shift[0] / pix_size
data.y += shift[1] / pix_size

mwrfits, data, outfile, evthdr,/create
mwrfits, gti, outfile, gtihdr

END



