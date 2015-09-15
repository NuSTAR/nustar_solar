;+
; NAME:			align_tile.pro
;
; PURPOSE:	
;		Perform cross-correlation of one NuSTAR mosaic tile and an AIA image to find
;		NuSTAR aspect correction for that tile.  The AIA image should be a Level 1.5 image
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
;		align_tile, orbit, mos, wave=wave		; examine this to see how well it worked.
;		align_tile, orbit, mos, wave=wave, /write		; if you like it, write to file.
;
; INPUTS:
;			orbit		For the April 29 obs, choose 1 or 2
;			mos			Mosaic tile #
;			
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
;			2015-July-05		LG	Created routine.
;-


PRO	ALIGN_TILE, orbit, mos, write=write, wave=wave, fov=fov, aia_dir=aia_dir, $
	nu_dir=nu_dir, out_dir=out_dir, shift_manual=shift_manual, $
	log=log, levels=levels, stop=stop

	default, write, 0
	default, fov, 8
	default, log, 0
	default, levels, [20,30,50,70,90]
	default, aia_dir, '~/data/aia/20150429/'
	default, nu_dir,  './maps/'
	default, out_dir, 'tiles/'
	
	if not keyword_set( wave ) then begin
		print, 'AIA wavelength required'
		return
	endif

	; aia_lct, wave=wave, /load
	loadct, 5		; This highlights bright spots more vividly than AIA color tables.

	; aia_dir = '~/data/aia/20150429/'
	faia_stem = 'AIA*' + strtrim(wave,2) + '.fits'
	faia = file_search( aia_dir + faia_stem )

	; Identify which NuSTAR maps to use.
	; nu_dir = './maps/'
	f_nu = file_search( nu_dir+'maps*' )
	undefine, all_mos
	for i=0, n_elements(f_nu)-1 do push, all_mos, strmid( f_nu[i], 3+strpos(f_nu[i],'MOS'), 2)
	i = where( all_mos eq mos )
	if i[0] eq -1 then begin
		print, 'Mosaic tile # not found.'
		return
	endif
	n_chu = n_elements(i)

for j=0, n_chu-1 do begin

	; Get some config info.
	CHU = strmid( f_nu[i[j]], 3+strpos(f_nu[i[j]],'CHU'), 3)
	FPM = strmid( f_nu[i[j]], 3+strpos(f_nu[i[j]],'FPM'), 1)

;	out_file = out_dir + 'orbit'+strtrim(orbit,2)+'/mos'+strtrim(mos,2)
	out_file = out_dir + 'mos'+strtrim(mos,2)
	if n_chu gt 1 then out_file = out_file + '_chu' + chu

	restgen, m_nu, file=f_nu[i[j]]
	;plot_map, m_nu
	nu_time = anytim( '29-Apr-2015 '+strmid( m_nu.time, 12, 8) )
	ptim, nu_time

	undefine, aia_time
	for k=0, n_elements(faia)-1 do push, aia_time, strmid( faia[k], 3+strpos(faia[k],'AIA'), 15)
	for k=0, n_elements(faia)-1 do aia_time[k]=strmid(aia_time[k],0,4)+'-'+strmid(aia_time[k],4,2)+'-'+strmid(aia_time[k],6,2)+' '+strmid(aia_time[k],9)
	for k=0, n_elements(faia)-1 do aia_time = anytim( aia_time )
	close=closest( aia_time-aia_time[0], nu_time-aia_time[0] )
	fits2map, faia[close], maia

	; If desired, you can smooth the NuSTAR map.
	m_nu.data = gauss_smooth( m_nu.data, 3 )

	cen = map_centroid( m_nu, thr=0.5*max(m_nu.data) )

	saia = make_submap( maia, cen=cen, fov=fov )
	s_nu = make_submap( m_nu, cen=cen, fov=fov )

	; Do the cross correlation.
	; Alternatively, this part can be skipped and the next section can be used to
	; adjust the correction until it fits "by eye"

	nu_dim = fix(fov*60./m_nu.dx)
	nu_sub  = make_submap( m_nu, cen=cen, fov=fov, dim=nu_dim*[1,1] )
	aia_image = saia.data
	sz = size( aia_image, /dim )
	cube = fltarr( sz( 0 ), sz( 1 ), 2 )
	; Rebin coarser (NuSTAR) to finer (AIA) image.
	rsub_nu = coreg_map( nu_sub, saia, /rescale, /no_project )  
	cube( *, *, 0 ) = rsub_nu.data
	cube( *, *, 1 ) = saia.data

	; Use cross-correlation to find the pixel offsets and create a new NUSTAR map with corrected pointing.

	offsets = get_correl_offsets( cube )
	;	print, offsets
	correct_nu = shift_map( nu_sub, (-1)*offsets( 0, 1 ) * saia.dx, $
	                                (-1)*offsets( 1, 1 ) * saia.dy )

	;	plot_map, saia
	;	plot_map, correct_nu, /over

	; Here, put in your own offsets if you want, or use the ones from the cross correlation.
	shift = fix( reform(-offsets[*,1])*rsub_nu.dx )
	if keyword_set( shift_manual ) then shift = shift_manual

	; Plot the uncorrected and corrected overlays side-by-side
	if write then popen, out_file, xsi=8, ysi=4
	if write then thick=3 else thick=1
	if write then ch=0.8 else ch=1
	!p.multi=[0,2,1]
	plot_map, saia, /nodate, charsi=ch, log=log
	plot_map, s_nu, /over, thick=thick, col=255, lev=levels, /per
	;xyouts, cen[0]-400,cen[1]-375,'Orbit 1 Tile '+strtrim(MOS,2)+' FPM'+fpm, col=255, charth=1
	;xyouts, cen[0]-400,cen[1]-400,'CHU'+chu, col=255
	xyouts, 0.1, 0.25, 'Orbit 1 Tile '+strtrim(MOS,2)+' FPM'+fpm, col=255, charth=1, /norm
	xyouts, 0.1, 0.2,  'CHU'+chu, col=255, charth=1, /norm
	plot_map, saia, /nodate, charsi=ch, log=log
	plot_map, shift_map( s_nu, shift[0], shift[1]), /over, thick=thick, col=255, lev=levels, /per
	xyouts, 0.6,0.2, 'Shift ['+strtrim(shift[0],2)+','+strtrim(shift[1],2)+'] arcsec', col=255, charth=1, /norm
	if write then pclose

if keyword_set( stop ) then stop

endfor

return

END