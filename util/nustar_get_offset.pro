FUNCTION nustar_get_offset, infile



   db_root = '../offset_files'

   ; Parse relevant information out of the filename

   chu = (strsplit(infile, '_', /extract))[2]
   chu = (strsplit(chu, '.', /extract))[0]



   seqid= strmid(infile, 2+strpos(infile, 'nu'), 11)
   fpm = 'FPM'+strmid(infile, 13+strpos(infile, 'nu'), 1)    



   ; Find the offset file
   dirpath = db_root + '/'+seqid+'/'+chu
   offset_file = dirpath+'/offset_'+fpm+'.txt'


   IF ~file_test(offset_file) THEN message, procname+': Offset file not found'+offset_file

   openr, lun, offset_file, /get_lun
   input = 'string'
   readf, lun, input
   close, lun, lun
   fields = strsplit(input, ' ' , /extract)

   offset = [fix(fields[0]), fix(fields[1])]
   return, offset

END
