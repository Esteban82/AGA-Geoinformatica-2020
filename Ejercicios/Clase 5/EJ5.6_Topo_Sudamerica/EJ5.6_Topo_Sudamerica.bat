ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Resolucion de SRTM: 01d, 30m, 20m, 15m, 10m, 06m, 05m, 04m, 03m, 02m, 01m, 30s, 15s, 03s, 01s
REM	Puede haber problemas para descargar las resoluciones de 05m a 01s
	SET	RES=06m

REM	Titulo del mapa
	SET	title=EJ5.6_Topo_Sudamerica
	echo %title%

REM	Region: Sudamerica
	SET	REGION=-90/-20/-60/20
	
REM	Proyeccion Mercator (M)
	SET	PROJ=M15c

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	CUT=temp_%title%.grd
	SET	color=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.grd

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------

REM	Sub-seccion MAPA
	gmtset FORMAT_GEO_MAP ddd:mm:ssG
	gmtset MAP_FRAME_AXES WesN
	gmtset MAP_FRAME_TYPE fancy+
	gmtset MAP_FRAME_WIDTH 0.1
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0.3	
	gmtset MAP_SCALE_HEIGHT 0.1618
	gmtset MAP_TICK_LENGTH_PRIMARY 0.1

	gmtset GMT_VERBOSE w

REM	Sub-seccion PS
	gmtset PS_MEDIA A3

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Recortar Grilla
rem	gmt grdcut "GMRTv3_5.grd" -G%CUT% -R
rem	gmt grdcut "@earth_relief_%RES%_g" -G%CUT% -R
rem	pause

REM	Extraer informacion de la grilla recortada para determinar rango de CPT
rem	grdinfo %CUT%
	grdinfo %CUT% -T50
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
rem	gmt makecpt -Cglobe  -T-8400/5700/50  -Z > %color%
rem	gmt makecpt -Cearth  -T-8400/5700/50  -Z > %color%
rem	gmt makecpt -Cetopo1 -T-8400/5700/50  -Z > %color%
rem	gmt makecpt -Cgeo    -T-8400/5700/50  -Z > %color%
rem	gmt makecpt -Crelief -T-8400/5700/50  -Z > %color%
rem	gmt makecpt -Cworld  -T-8400/5700/50  -Z > %color%
rem	gmt makecpt -Coleron -T-8400/6050/50  -Z > %color%

REM	Combinacion 1
rem	gmt makecpt -Cbathy -T-8400/0/10 -Z -N >  %color%
rem	pause
rem	gmt makecpt -Cdem3  -T0/6050/50  -Z    >> %color%
rem	pause

REM	Combinacion 2
rem	gmt makecpt -Cibcso     -T-8400/0/10 -Z -N  >  %color%
rem	gmt makecpt -Celevation -T0/6050/50  -Z     >> %color%

REM	Combinacion 3
rem	gmt makecpt -Cbathy -T-8400/0/10 -Z -N >  %color%
rem	gmt makecpt -Cgray  -T0/6050/50  -Z    >> %color%

REM	Combinacion 4
	gmt makecpt -Cbathy -T-8400/0/10 -Z -N  >  %color%
	gmt makecpt -Cgray  -T0/6050/50  -Z -I  >> %color%

REM	Combinacion 5
rem	gmt makecpt -Cocean -T-8400/0/10  -Z -N  >  %color%
rem	gmt makecpt -Ccopper -T0/6050/50  -Z -I  >> %color%

REM	Combinacion 6
rem	gmt makecpt -Coslo   -T-8400/0/10 -Z -N  >  %color%
rem	gmt makecpt -Cbilbao -T0/6050/50  -Z -I  >> %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A). 
rem	gmt grdgradient %CUT% -A270 -G%SHADOW% -Ne0.5

REM	Crear Imagen a partir de grilla con sombreado y cpt
	gmt grdimage -R -J -O -K %CUT% -C%color% >> %OUT% -I%SHADOW%

REM	Agregar escala de colores a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
	gmt psscale -R -J -O -K -DJRM+o0.3c/0+w15/0.618c -C%color% -Ba1+l"Elevaciones (km)"  -I >> %OUT% -W0.001

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar frame
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf 

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -D%D%  >> %OUT% -W1/faint

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

rem	pause
rem	del temp_* %OUT% gmt.*

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Probar las paleta de Colores globales con hinge (líneas 62-68).
REM	2. Probar las paletas combinadas (lineas 74-92).


