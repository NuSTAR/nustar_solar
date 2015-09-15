PRO nustar_combine_maps, list, outfile = outfile
procname = 'nustar_combine_maps'
nfiles = n_elements(list)

FOR i = 0, nfiles -1 DO BEGIN
   IF ~file_test(list[i]) THEN message, procname+': File not found'+list[i]
                                ; Read in the map
   fits2map, list[i],ns_map
   IF n_elements(all_map) EQ 0 THEN all_map = ns_map ELSE all_map.data += ns_map.data
ENDFOR
map2fits, all_map, outfile

END

