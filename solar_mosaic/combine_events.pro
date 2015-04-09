pro combine_events, obs_list

  ; Get all of the events and housekeeping data:
  outfile = getenv('mosaic_outfile')


  ab = ['A', 'B']
  for iab = 0, 1 do begin
     for obs = 0, n_elements(obs_list) -1 do begin
        datpath = file_search(obs_list[obs]+'/*', /test_dir)
        
        evtfiles = file_search(datpath+'/event_cl/', '*'+ab[iab]+'06_cl_sunpos.evt')
        
        for i = 0, n_elements(evtfiles) -1 do begin
           evt=mrdfits(evtfiles[i],1,evth)
           use = bytarr(n_elements(evt)) + 1 

           ; Filter out bad pixels here:
           for det = 0, 3 do begin

              thisdet = where(evt.det_id eq det)
              if iab eq 0 and det eq 2 then begin
                 badones = where(evt[thisdet].rawx eq 16 and evt[thisdet].rawy eq 5, nbad)
                 if nbad gt 0 then $
                    use[thisdet[badones]]=0
                 
                 badones = where(evt[thisdet].rawx eq 24 and evt[thisdet].rawy eq 22, nbad)
                 if nbad gt 0 then $
                    use[thisdet[badones]]=0
                 
              endif

              if iab eq 0 and det eq 3 then begin
                 badones = where(evt[thisdet].rawx eq 22 and evt[thisdet].rawy eq 1, nbad)
                 if nbad gt 0 then $
                    use[thisdet[badones]]=0
                 
                 badones = where(evt[thisdet].rawx eq 15 and evt[thisdet].rawy eq 3, nbad)
                 if nbad gt 0 then $
                    use[thisdet[badones]]=0
              endif
           endfor

           
           push, all_evt, evt[where(use)]             
        endfor
     endfor
     
     mwrfits, all_evt, outfile, evth, /create   
     return
     
  end
