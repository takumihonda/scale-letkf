function plot (args)

name = '700_temp'

tstring = subwrd(args, 1)
trun = subwrd(args, 2)
tfilename = subwrd(args, 3)

'setrgb.gs'

outf = 'out/'name'_'tfilename

'domain.gs'
'set lev 700'

'set gxout shaded'
'set clevs -1e9 70 80 90'
'set ccols 17 0 211 212 213'
'd const(rh, -1e10, -u)'
'cbarn.gs 0.8 0 5.5 0.7 0.8 1'

'set gxout barb'
'set ccolor 4'
'set cthick 3'
'set digsiz 0.042'
'd skip(u*1.94384,8,8);skip(v*1.94384,4,4)'

'temps=smth9(temp)'

'set gxout contour'
'set clevs 3 9'
'set ccolor 201'
'set cthick 4'
'set cstyle 3'
'set clab off'
'd temps-273.15'
'set clevs -45 -39 -33 -27 -21 -15 -9 -3'
'set ccolor 203'
'set cthick 4'
'set cstyle 3'
'set clab off'
'd temps-273.15'
'set clevs 6 12 15 18 21 24 27 30 33 36 39 42 45 48'
'set ccolor 201'
'set cthick 4'
'set cstyle 3'
'set clab on'
'd temps-273.15'
'set clevs 0'
'set ccolor 202'
'set cthick 6'
'set cstyle 3'
'set clab on'
'd temps-273.15'
'set clevs -48 -42 -36 -30 -24 -18 -12 -6'
'set ccolor 203'
'set cthick 4'
'set cstyle 3'
'set clab on'
'd temps-273.15'


'set gxout shaded'
'set clevs 0'
'set ccols 17 17'

'set string 1 c 5'
'set strsiz 0.09 0.12'
'draw string 5.5 7.5 `1700 hPa RH (%) / Temp (C) / Wind (kts)  [ Run: `0'trun'`1 | VT: `0'tstring'`1 ]'


'!rm -f 'outf'_tmp.png'
'gxprint 'outf'_tmp.png'
'!convert -trim +repage 'outf'_tmp.png 'outf'.png'
'!rm -f 'outf'_tmp.png'


return