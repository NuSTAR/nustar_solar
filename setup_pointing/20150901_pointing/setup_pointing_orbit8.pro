pro setup_pointing_orbit8
                                ; Orbit 3 start:

  tstart_orb1 = '2015-09-02T10:25'
  tend_orb1 = '2015-09-02T11:26'

  outstem = '20150902'
  suffix='orbit8'
  tstart_sec = convert_nustar_time(tstart_orb1, /from_ut)
  tend_sec = convert_nustar_time(tend_orb1, /from_ut)

  aim_times = 0.5 * (tstart_sec + tend_sec)
  aim_times = convert_nustar_time(aim_times, /mjd) + 2400000.5

  restore, 'sun_ephemeris.sav'

; aim_times = dindgen(tiles) * dwell + tstart_jd[0]



;  print, 'Time for last dwell: ', convert_nustar_time(max(aim_times) - 2400000.5+dwell, /from_mjd, /ut)

   
  sun_ra = interpol(ephem.ra, ephem.jd, aim_times)
  sun_dec = interpol(ephem.dec, ephem.jd, aim_times)
  sun_pa = interpol(ephem.pa, ephem.jd, aim_times)
  sun_rad = interpol(ephem.rad, ephem.jd, aim_times)

  ; The PA angle you want to use:

  offset_pa = (254. + sun_pa + 90) mod 360.  ; degrees



  offset_rad = sun_rad + (3 * 60.) ; 1 arcminute1 off the solar limb.

  delx = -offset_rad * cos(offset_pa * !dtor)
  dely = offset_rad * sin(offset_pa * !dtor)

  box_pa = (sun_pa + 135) mod 360
                                ; Roll angle to get "diamond" shape

  print, 'Box PA angle:', box_pa[0]
  
  delx /= 3600. ; convert to degrees
  dely /= 3600.

  point_ra = sun_ra + delx / cos(sun_dec * !dtor)
  point_dec = sun_dec + dely




  openw, lun, /get_lun, 'test_boxes_'+suffix+'.reg'
  printf, lun, "# Region file format: DS9 version 4.1"
  printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
  printf, lun, 'fk5'
  for i = 0, n_elements(point_ra) -1 do begin


;     box(22:53:45.512,-7:05:41.18,720",720",113)

     printf, lun, 'box('+ $
             string(point_ra[i], format ='(d8.4)')+','+$
             string(point_dec[i],  format ='(d8.4)')+','+$
             '720", 720", '+string(box_pa[i], format = '(d0.0)')+')'
  ;; endfo
  ;; close, lun
  ;; free_lun, lun
  
  ;; openw, lun, /get_lun, 'test_sun.reg'
  ;; printf, lun, "# Region file format: DS9 version 4.1"
  ;; printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
  ;; printf, lun, 'fk5'

     printf, lun, 'circle('+ $
             string(sun_ra[i], format ='(d8.4)')+','+$
             string(sun_dec[i],  format ='(d8.4)')+','+$
             string(sun_rad[i],  format ='(d8.4)')+'")'
     printf, lun, '# vector('+$
             string(sun_ra[i], format ='(d8.4)')+','+$
             string(sun_dec[i],  format ='(d8.4)')+','+$
             string(sun_rad[i],  format ='(d8.4)')+'",'+$
             string((sun_pa[i] + 90) mod 360,   format ='(d8.4)')+') vector=1'


  endfor
  
  close, lun
  free_lun, lun


  for i = 0, n_elements(point_ra) -1 do begin
     openw, lun, /get_lun, 'box_'+string(i, format = '(i0)')+'_'+suffix+'.reg'
     printf, lun, "# Region file format: DS9 version 4.1"
     printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
     printf, lun, 'fk5'
  


;     box(22:53:45.512,-7:05:41.18,720",720",113)
     
     printf, lun, 'box('+ $
             string(point_ra[i], format ='(d8.4)')+','+$
             string(point_dec[i],  format ='(d8.4)')+','+$
             '720", 720", '+string(box_pa[i], format = '(d0.0)')+')'

;     close, lun
;     free_lun, lun
  
;     openw, lun, /get_lun, 'sun_'+string(i, format = '(i0)')+'.reg'
;     printf, lun, "# Region file format: DS9 version 4.1"
;     printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
;     printf, lun, 'fk5'

     printf, lun, 'circle('+ $
             string(sun_ra[i], format ='(d8.4)')+','+$
             string(sun_dec[i],  format ='(d8.4)')+','+$
             string(sun_rad[i],  format ='(d8.4)')+'")'

     printf, lun, '# vector('+$
             string(sun_ra[i], format ='(d8.4)')+','+$
             string(sun_dec[i],  format ='(d8.4)')+','+$
             string(sun_rad[i],  format ='(d8.4)')+'",'+$
             string((sun_pa[i] + 90) mod 360,   format ='(d8.4)')+') vector=1'

     
     close, lun
     free_lun, lun

  endfor
  



  openw, lun, /get_lun, outstem+'_pointings_'+suffix+'.txt'
  for i = 0, n_elements(sun_ra) - 1 do begin
;     this_time = convert_nustar_time(aim_times[i] - 2400000.5, /from_mjd, /ut)
     
     printf, lun, tstart_orb1, point_ra[i], point_dec[i], format = '(A, " ", 2d12.5)'
  endfor
  close, lun
  free_lun, lun




  openw, lun, /get_lun, outstem+'_pointings_withsun_'+suffix+'.txt'
  for i = 0, n_elements(sun_ra) - 1 do begin
     this_time = convert_nustar_time(aim_times[i] - 2400000.5, /from_mjd, /ut)
     printf, lun, this_time, point_ra[i], point_dec[i],sun_ra[i], sun_dec[i],sun_pa[i], format = '(A," ", 5d12.5)'
  endfor
  close, lun
  free_lun, lun
  
     


  
  
  


  

end
