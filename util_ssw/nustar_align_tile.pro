;+
; NAME:			nustar_align_tile.pro
;
; PURPOSE:	
;		Perform cross-correlation of one NuSTAR mosaic tile
;		and a referenrce image to find
;		NuSTAR aspect correction for that tile.
;               
;               (Out of date?) The AIA image should be a Level 1.5 image
;		whose filename begins with 'AIA'.
;
;	NOTES:	
;		There isn't an explicit option to choose FPMA or FPMB at the moment.
;		Code was written for the 2015 April 29 observation.  Changes needed to work
;		with other observations would not be surprising.
;
; EXAMPLE:
;		wave = 94
;		orbit = 1
;		mos = 10
;		nustar_align_tile, reference_file, nustar_file
;		nustar_align_tile, reference_file, nustar_file, wave=wave, /write		; if you like it, write to file.
;
; INPUTS:
;			reference_file 		This is a map file that want to correct to already
;                       nustar_file             NuSTAR map file
; KEYWORDS:
;			wave		Actually, this is required.  AIA wavelength to coalign to.
;			write		If set, write the resulting plots to file.
;			fov			FOV to use in submaps, default 8 arcmin
;			aia_dir		Where to find the AIA data. Must be Level 1.5 data!
;			nu_dir		Where to find the NuSTAR sun-corrected event lists.
;			out_dir		Where to write the plots, if /write is set.
;			shift_manual	An optional shift put in "by hand" instead of using the cross-correlation.
;			log			Plots are on log scale
;			levels	Contour levels to use in overplots
;		
;	DEPENDENCIES:
;			Must have general SSW libraries installed ($SSW/gen/idl)
;			Requires add'l routines map_centroid.pro, make_submap.pro, popen.pro, and pclose.pro
;			Also needs push.pro, which is in the nustar-idl directory
;
; MODIFICATION HISTORY:
;                       2015-Sep-13             BG      Heavily modified previous code, but kept the alignment steps. 
;			2015-July-05		LG	Created routine.
;-


PRO	NUSTAR_ALIGN_TILE, ref_file, map_file, $
                           log = log, levels = levels, fov= fov,$
                           figdir = figdir, datdir= datdir

procname='nustar_align_tile'

	;; default, write, 0
default, fov, 10
default, log, 0
default, levels, [20,30,50,70,90]
default, figdir, './figs'
default, datdir, './dat'
        
IF ~file_test(ref_file) THEN message, procname+': File not found '+ref_file
faia = ref_file
IF ~file_test(map_file) THEN message, procname+': File not found '+map_file
outfile = figdir+'/'+file_basename(map_file, 'map.fits')+'offset.ps'
savfile = datdir+'/'+file_basename(map_file, 'map.fits')+'offset.sav'

        ; Read in the referece map
fits2map, ref_file, maia
        ; Read in the NuSTAR data
fits2map, map_file, m_nu


	; If desired, you can smooth the NuSTAR map.
m_nu.data = gauss_smooth( m_nu.data, 3 )

cen = nustar_map_centroid( m_nu, thr=0.5*max(m_nu.data) )
saia = nustar_make_submap( maia, cen=cen, fov=fov )
s_nu = nustar_make_submap( m_nu, cen=cen, fov=fov )


	; Do the cross correlation.
	; Alternatively, this part can be skipped and the next section can be used to
	; adjust the correction until it fits "by eye"

nu_dim = fix(fov*60./m_nu.dx)
nu_sub  = nustar_make_submap( m_nu, cen=cen, fov=fov, dim=nu_dim*[1,1] )
aia_image = saia.data
sz = size( aia_image, /dim )

cube = fltarr( sz( 0 ), sz( 1 ), 2 )
	; Rebin coarser (NuSTAR) to finer (AIA) image.
        ; Should this be the other way?
rsub_nu = coreg_map( nu_sub, saia, /rescale, /no_project )  
cube( *, *, 0 ) = rsub_nu.data
cube( *, *, 1 ) = saia.data

	; Use cross-correlation to find the pixel offsets and create a new NUSTAR map with corrected pointing.
offsets = get_correl_offsets( cube )

shift = -1. * reform(offsets[*, 1]) 
;print, shift
                                ; Here, put in your own offsets if you want, or use the ones from the cross correlation.
shift = fix( reform(-offsets[*,1])*rsub_nu.dx ) ; Arcseconds

save, shift, ref_file, map_file, file = savfile
        
cgps_open, outfile, $
           /encapsulated, /nomatch, /inches, $
           xsize=5, ysize=5

;!p.multi=[0,2,1]
loadct, 5                       ; This highlights bright spots more vividly than AIA color tables.
plot_map, saia, /nodate, charsi=ch, log=log, position=[0.15,0.1,0.95,0.9], title = ''
plot_map, s_nu, /over, thick=thick, col=255, lev=levels, /per, position=[0.15,0.1,0.9]
                                ;xyouts, cen[0]-400,cen[1]-375,'Orbit 1 Tile '+strtrim(MOS,2)+' FPM'+fpm, col=255, charth=1
                                ;xyouts, cen[0]-400,cen[1]-400,'CHU'+chu, col=255
;xyouts, 0.1, 0.25, 'Orbit 1 Tile '+strtrim(MOS,2)+' FPM'+fpm, col=255, charth=1, /norm
;xyouts, 0.1, 0.2,  'CHU'+chu, col=255, charth=1, /norm
plot_map, saia, /nodate, charsi=ch, log=log, position=[0.15,0.1,0.95,0.9], title = ''
plot_map, shift_map( s_nu, shift[0], shift[1]), /over, thick=thick, col=255, lev=levels, /per, position=[0.15,0.1,0.95,0.9]
;xyouts, 0.6,0.2, 'Shift ['+strtrim(shift[0],2)+','+strtrim(shift[1],2)+'] arcsec', col=255, charth=1, /norm

cgps_close

return
	;; correct_nu = shift_map( nu_sub, (-1)*offsets( 0, 1 ) * saia.dx, $
	;;                                 (-1)*offsets( 1, 1 ) * saia.dy )

	;	plot_map, saia
	;	plot_map, correct_nu, /over


	;; ; Plot the uncorrected and corrected overlays side-by-side
	;; if write then popen, out_file, xsi=8, ysi=4
	;; if write then thick=3 else thick=1
	;; if write then ch=0.8 else ch=1
;	if write then pclose

;if keyword_set( stop ) then stop

;endfor

return

END
