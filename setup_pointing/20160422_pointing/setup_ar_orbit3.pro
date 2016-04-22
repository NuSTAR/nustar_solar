pro setup_ar_orbit3

                                ; Orbit 1 start:

  tstart_orb1 = '2016-04-22T21:07:00'
  tend_orb1 = '2016-04-22T21:24:00'

  outstem = '20160422'
  suffix='ar_orbit3'
  tstart_sec = convert_nustar_time(tstart_orb1, /from_ut)
  tend_sec = convert_nustar_time(tend_orb1, /from_ut)

  tiles = 1.
  dwell = (double((tend_sec - tstart_sec) / tiles))[0]
;  dwell = double((tend_sec - tstart_sec))

  print, 'Time per tile: ',  dwell


  tstart_jd = convert_nustar_time(tstart_orb1, /from_ut, /mjd) + 2400000.5


  restore, 'sun_ephemeris.sav'

                                ; Aim point/times
;  dwell = double(220.)          ; seconds
  dwell /= 86400.               ; days
  aim_times = dindgen(tiles) * dwell + tstart_jd[0] + dwell * 0.5

;  print, 'Time for last dwell: ', convert_nustar_time(max(aim_times) - 2400000.5, /from_mjd, /ut)
  for i = 0, n_elements(aim_times) -1 do $ 
     print, 'Aim times for last dwell: ', convert_nustar_time(aim_times[i] - 2400000.5, /from_mjd, /ut)


  

   
  sun_ra = interpol(ephem.ra, ephem.jd, aim_times)
  sun_dec = interpol(ephem.dec, ephem.jd, aim_times)
  sun_pa = interpol(ephem.pa, ephem.jd, aim_times)





                                ; Roll angle to get "diamond" shape
  print, 'Celestial Sun NP angle: ', sun_pa
  print, 'Sun NP angle for ds9: ', (sun_pa+90) mod 360  

  box_pa = (sun_pa+ 90) mod 360 + 5.
  print, 'Box roll angle wrt celestial north: ', box_pa
  

  ; From David:
  xsteps = -140.d 
  ysteps = 175.d

  xsteps = -213.d
  ysteps = 183.d

  ; CCW rotation to go from heliocentric to celestial:
  delx = xsteps * cos(sun_pa * !dtor) + ysteps * sin(sun_pa*!dtor)
  dely = -xsteps * sin(sun_pa * !dtor) + ysteps * cos(sun_pa*!dtor)

   
  delx /= 3600
  dely /= 3600

  for i = 0, tiles - 1 do begin
     push, delx, delx
     push, dely, dely
  endfor
  
  point_ra = sun_ra + delx / cos(sun_dec * !dtor)
  point_dec = sun_dec + dely
  
  openw, lun, /get_lun, 'test_boxes_'+suffix+'.reg'
  printf, lun, "# Region file format: DS9 version 4.1"
  printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
  printf, lun, 'fk5'
  for i = 0, n_elements(point_ra) -1 do begin


;     box(22:53:45.512,-7:05:41.18,720",720",113)

     printf, lun, 'box('+ $
             string(point_ra[i], format ='(d10.4)')+','+$
             string(point_dec[i],  format ='(d10.4)')+','+$
             '720", 720", '+string(box_pa[i], format = '(d0.0)')+')'
  ;; endfo
  ;; close, lun
  ;; free_lun, lun
  
  ;; openw, lun, /get_lun, 'test_sun.reg'
  ;; printf, lun, "# Region file format: DS9 version 4.1"
  ;; printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
  ;; printf, lun, 'fk5'

     printf, lun, 'circle('+ $
             string(sun_ra[i], format ='(d10.4)')+','+$
             string(sun_dec[i],  format ='(d10.4)')+','+$
             '960.5"'+')'
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
             string(point_ra[i], format ='(d10.4)')+','+$
             string(point_dec[i],  format ='(d10.4)')+','+$
             '720", 720", '+string(box_pa[i], format = '(d0.0)')+')'

;     close, lun
;     free_lun, lun
  
;     openw, lun, /get_lun, 'sun_'+string(i, format = '(i0)')+'.reg'
;     printf, lun, "# Region file format: DS9 version 4.1"
;     printf, lun, 'global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1'
;     printf, lun, 'fk5'

     printf, lun, 'circle('+ $
             string(sun_ra[i], format ='(d10.4)')+','+$
             string(sun_dec[i],  format ='(d10.4)')+','+$
             '960.5"'+')'
     
     close, lun
     free_lun, lun

  endfor
  



  openw, lun, /get_lun, outstem+'_pointings_'+suffix+'.txt'
  for i = 0, n_elements(sun_ra) - 1 do begin
     this_time = convert_nustar_time(aim_times[i] - 2400000.5, /from_mjd, /ut)

     printf, lun, this_time, point_ra[i], point_dec[i], format = '(A, " ", 2d12.5)'
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
