; Runs the pipeline for a given CHU combination.

PRO nustar_split_chufiles, indir, gtidir, evtdir

seqdir = file_dirname(indir)

seqid = file_basename(seqdir)
gti_files = file_search(gtidir+'/nu'+seqid+'*gti*fits')

ab = ['A', 'B']


FOR i = 0, n_elements(gti_files) -1 DO BEGIN
   suffix = (strsplit(gti_files[i], '_', /extract))[2]

   cmd = './run_pipe_usrgti.sh '+seqdir+' '+evtdir+' '+gti_files[i]
   spawn, cmd

   FOR iab = 0, 1 DO BEGIN
      outfile = evtdir+'/nu'+seqid+ab[iab]+'06_cl.evt'

      newfile = evtdir+'/nu'+seqid+ab[iab]+'06_cl_'+suffix+'.evt'
      spawn, 'mv '+outfile+' '+newfile
   ENDFOR

ENDFOR



END
