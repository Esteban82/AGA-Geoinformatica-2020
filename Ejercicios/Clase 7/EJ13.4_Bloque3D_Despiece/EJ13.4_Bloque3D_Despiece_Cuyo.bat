ECHO OFF
cls


REM	Definir Variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ13.4_Bloque3D_DESPIECE_Cuyo
	echo %title%

REM	Region: Cuyo
	SET	REGION=-72/-64/-35/-30
	SET	REGION3D=%REGION%/-5000/7000
	SET	REGION3D=%REGION%/-10000/10000

REM	Proyeccion Mercator (M)
	SET	PROJ=M14c

REM	Escala vertical 
	SET	PROZ=5c

REM	Perpesctiva
	SET	p=160/30

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=f

REM 	Nombre archivo de salida y Variables Temporales
	SET	CUT=temp_%title%.nc
	SET	COLOR=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.nc
	SET	OUT=%title%.ps

REM	Parametros Generales
REM	-----------------------------------------------------------------------------------------------------------
REM	Sub-seccion FUENTE
	gmtset FONT_ANNOT_PRIMARY 8,Helvetica,black
	gmtset FONT_LABEL 8,Helvetica,black

REM	Sub-seccion FORMATO
	gmtset FORMAT_GEO_MAP ddd:mm:ssF

REM	Sub-seccion GMT
	gmtset GMT_VERBOSE w

REM	Sub-seccion MAPA
	gmtset MAP_FRAME_TYPE fancy
	gmtset MAP_FRAME_WIDTH 0.1
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0
	gmtset MAP_SCALE_HEIGHT 0.1618
	gmtset MAP_TICK_LENGTH_PRIMARY 0.1

REM	Sub-seccion PS
	gmtset PS_MEDIA A3

REM	Procesar Grillas
REM	-----------------------------------------------------------------------------------------------------------

REM	Recortar Grilla
	gmt grdcut "GMRTv3_1.grd" -G%CUT% -R%REGION%

REM	Informacion Grilla
rem	grdinfo %CUT% -T10

REM	Crear Paleta de Color
	gmt makecpt -Cdem4 -T0/7000/250 -Z > %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -A%A% -G%SHADOW% -Ne0.5

REM	Dibujar Figura
REM	---------------------------------------------------------------------------------------------------------
rem	Abrir archivo de salida (ps)
	gmt psxy -R%REGION3D% -J%PROJ% -JZ%PROZ% -p%p% -T -K -P > %OUT%

REM	Bloque 3D topografico 
	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT% -BnSwEZ -Baf -Bzaf+l"Altura (Km)" 

REM	Pintar Oceanos (-S) y Lineas de Costa
	gmt pscoast -R -J -JZ -O -K -D%D% >> %OUT% -p%p%/0 -Sdodgerblue2 -A0/0/1
	gmt pscoast -R -J -JZ -O -K -D%D% >> %OUT% -p%p%/0 -W1/0.3,black 

REM	***********************************************************************************************************
REM	Transicion Figura 1-2. Desplazamiento en eje Y (del grafico).
	gmt psxy -R -J -JZ -O -K -p%p% -T >> %OUT% -Y7.5c
REM	***********************************************************************************************************

REM	Bloque 3D topo+satelital con solo eje Z
	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 >> %OUT% -I%SHADOW% -G"Imagen_Geo.tif" -BZ -Bzaf+l"Altura (m)"

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -JZ -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp_* gmt.*
	del %OUT%
rem	pause

REM	Ejercicios sugeridos
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Cambiar la perspectiva de los mapas (linea 22) y ajustar la distancia entre los 2 mapas (linea 84) para que no superpongan.
