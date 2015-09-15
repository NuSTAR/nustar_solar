FUNCTION	NUSTAR_MAP_CENTROID, MAP, THRESHOLD=THRESHOLD, STOP=STOP, $
			UPPER=UPPER

;	Return the centroid position of a map in a 2-element array.
;	If THRESHOLD is set, then only pixels with values over the 
;	threshold will be included in the threshold calculation.
;	UPPER is an upper DN limit.  Data points above this limit
;	will not be included in the calculation.
; 
;       Originally pushed by LG, renamed by BG.
default, threshold, 0.

image = map.data
default, upper, max( image )

size = size(image)
nX = size[1]
nY = size[2]

i = where(image lt threshold or image gt upper)
if i[0] gt -1 then image[i] = 0.

centroid = centroid( image )
; if image sizes are even then centroid doesn't give a good result.
; kluge to adjust by half a pixel to correct for this.
if nx mod 2 eq 0 then centroid[0] += 0.5
if ny mod 2 eq 0 then centroid[1] += 0.5

coord_x = (centroid[0] - nX/2)*map.dx + map.xc
coord_y = (centroid[1] - nX/2)*map.dy + map.yc

if keyword_set(stop) then stop

return, [coord_x, coord_y]

END
