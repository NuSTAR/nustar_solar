pro nustar_plot_map, infile, outdir = outdir, $
                     smooth_radius = smooth_radius

IF ~keyword_set(smooth_radius) THEN smooth_radius = 2 

outfile = outdir+'/'+file_basename(infile, '.fits')+'.ps'

  
; Modified from IGH mapping scripts.

  ; Read in the map
   fits2map, infile,ns_map

   ; Use a pretty Brewer colortable
  cgloadct, /brewer, 25, /reverse

  tvlct,r,g,b,/get
  r[0]=0
  g[0]=0
  b[0]=0
  r[1]=255
  g[1]=255
  b[1]=255
  tvlct,r,g,b

  dnl=1.5
  dmx=3


 
  ;;;; Set the smoothing kernel here
  ns_map_smooth=ns_map
  ns_map_smooth.data=gauss_smooth(ns_map.data,smooth_radius)

  ;; Set the range here (log units in counts / sec)
  dnl=1.
  dmx = 4.
;  dmx=alog(max(ns_map_smooth.data * 1.05))


; Set the X/Y range here
  xrn=[600,2000]
  yrn=[-1000,400]

  cgps_open, outfile, $
             /encapsulated, /nomatch, /inches, $
             xsize=5, ysize=5

;  plot, ns_map_smooth.data
;  cgimage, ns_map_smooth.data, /keep, /scale


;   set_plot,'ps'
;   device, /encapsulated, /color, / isolatin1,/inches, $
;     bits=8, xsize=5, ysize=5,file='figs/'+suffix+'_EngCube_GO_FPMAB_'+eid+'_S.eps'
   plot_map,ns_map_smooth,/log,dmin=10^dnl,dmax=10^dmx,grid_sp=30,title='',$
     gcolor=0,bot=1,position=[0.15,0.1,0.95,0.9],chars=1,xrange=xrn,yrange=yrn
;title='FPMA+B G0 '+ename+' '+anytim(ma.time,/yoh,/trunc),grid_sp=30,$
   plot_map_cb_igh,[dnl,dmx],position=[0.6,0.85,0.9,0.87],color=0,chars=1,$
     cb_title='NuSTAR [log!D10!N]',bottom=1,format='(f4.1)'

   cgps_close
;   device,/close
;   set_plot, mydevice


;    stop
end
