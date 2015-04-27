pro setup_pointing_orbit2

                                ; Orbit 1 start:
  tstart_orb1 = '2015-03-02T23:43:00'
  tstart_jd = convert_nustar_time(tstart_orb1, /from_ut, /mjd) + 2400000.5


  restore, 'sun_ephemeris.sav'

                                ; Aim point/times
  dwell = double(210.)          ; seconds
  dwell = double(60 * 62. / 16) ; seconds (62 minute orbit)
  dwell /= 86400. ; days
  aim_times = dindgen(16) * dwell + tstart_jd[0]
  
  
  sun_ra = interpol(ephem.ra, ephem.jd, aim_times)
  sun_dec = interpol(ephem.dec, ephem.jd, aim_times)

  ;; for i = 0, n_elements(sun_ra) - 1 do begin
  ;;    sun_ra[i] = ephem[0].ra
  ;;    sun_dec[i] = ephem[0].dec
  ;; endfor
 
  
  xsteps = findgen(16) mod 4 - 1.5

  xsteps = [-1.5, -0.5, 0.5, 1.5]

  xsteps = [xsteps, reverse(xsteps), xsteps, reverse(xsteps)]

  ysteps = floor(findgen(16) / 4) - 1.5 

  xsteps = reverse(xsteps)
  ysteps = reverse(ysteps)
  
  
  
  sun_pa = 338.0996
  pa = (sun_pa + 135) mod 360
                                ; Roll angle to get "diamond" shape

  box_pa = pa
  pa = box_pa + 45 ; Offset to get the step in the right direction
  
  delx = xsteps * cos(pa * !dtor) - ysteps * sin(pa*!dtor)
  dely = xsteps * sin(pa * !dtor) + ysteps * cos(pa*!dtor)

                                ; Make the step size be ~10 arcminutes
  delx *= (10. / 60.)
  dely *= (10. / 60.)
  
  point_ra = sun_ra + delx / cos(sun_dec * !dtor)
  point_dec = sun_dec + dely

  openw, lun, /get_lun, 'test_boxes_orbit2.reg'
  printf, lun, "# Region file format: DS9 version 4.1"
  printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
  printf, lun, 'fk5'
  for i = 0, n_elements(point_ra) -1 do begin


;     box(22:53:45.512,-7:05:41.18,720",720",113)

     printf, lun, 'box('+ $
             string(point_ra[i], format ='(d8.4)')+','+$
             string(point_dec[i],  format ='(d8.4)')+','+$
             '720", 720", '+string(box_pa, format = '(d0.0)')+')'
  ;; endfor
  ;; close, lun
  ;; free_lun, lun
  
  ;; openw, lun, /get_lun, 'test_sun.reg'
  ;; printf, lun, "# Region file format: DS9 version 4.1"
  ;; printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
  ;; printf, lun, 'fk5'

  printf, lun, 'circle('+ $
          string(sun_ra[i], format ='(d8.4)')+','+$
          string(sun_dec[i],  format ='(d8.4)')+','+$
          '960.5"'+')'
endfor
  
  close, lun
  free_lun, lun


  for i = 0, n_elements(point_ra) -1 do begin
     openw, lun, /get_lun, 'box_'+string(i, format = '(i0)')+'_orbit2.reg'
     printf, lun, "# Region file format: DS9 version 4.1"
     printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
     printf, lun, 'fk5'
  


;     box(22:53:45.512,-7:05:41.18,720",720",113)
     
     printf, lun, 'box('+ $
             string(point_ra[i], format ='(d8.4)')+','+$
             string(point_dec[i],  format ='(d8.4)')+','+$
             '720", 720", '+string(box_pa, format = '(d0.0)')+')'

;     close, lun
;     free_lun, lun
  
;     openw, lun, /get_lun, 'sun_'+string(i, format = '(i0)')+'.reg'
     ;printf, lun, "# Region file format: DS9 version 4.1"
     ;printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
     ;printf, lun, 'fk5'

     printf, lun, 'circle('+ $
             string(sun_ra[i], format ='(d8.4)')+','+$
             string(sun_dec[i],  format ='(d8.4)')+','+$
             '960.5"'+')'
     
     close, lun
     free_lun, lun

  endfor
  



  openw, lun, /get_lun, '20150302_pointings_orbit2.txt'
  for i = 0, n_elements(sun_ra) - 1 do begin
     this_time = convert_nustar_time(aim_times[i] - 2400000.5, /from_mjd, /ut)
     printf, lun, this_time, point_ra[i], point_dec[i], format = '(A, " ", 2d12.5)'
  endfor
  close, lun
  free_lun, lun

  openw, lun, /get_lun, '20150302_pointings_withsun_orbit2.txt'
  for i = 0, n_elements(sun_ra) - 1 do begin
     this_time = convert_nustar_time(aim_times[i] - 2400000.5, /from_mjd, /ut)
     printf, lun, this_time, point_ra[i], point_dec[i],sun_ra[i], sun_dec[i], format = '(A," ", 4d12.5)'
  endfor
  close, lun
  free_lun, lun
  
     


  
  
  


  

end
