PRO run_pip_usrgti, gtidir, evtdir

gti_files = file_search(gtidir+'/nu*gti*fits')

FOR i = 0, n_elements(gti_files) -1 DO BEGIN
   print, gti_files

ENDFOR








END
