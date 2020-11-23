ECHO OFF
cls


REM	Definir Variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ13.1_Bloque3D_Jz
	echo %title%

REM	Region: Cuyo
	SET	REGION=-72/-64/-35/-30
	SET	BASE=-3500
	SET	TOP=7000	
	SET	REGION3D=%REGION%/%BASE%/%TOP%

REM	Proyeccion Mercator (M)
	SET	PROJ=M14c

REM	Escala vertical 
	SET	PROZ=4c
	SET	PROZ=0.1

REM	Perpesctiva
	SET	p=160/25

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

REM	-----------------------------------------------------------------------------------------------------------
REM	Procesar Grillas
REM	-----------------------------------------------------------------------------------------------------------
REM	Recortar Grilla
rem	gmt grdcut "GMRTv3_1.grd" -G%CUT% -R%REGION%
	
REM	Informacion Grilla
	grdinfo %CUT%
rem	pause

REM	Crear Paleta de Color
rem	gmt makecpt -Cdem4 -T0/7000/250 -Z > %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
rem	gmt grdgradient %CUT% -A160 -G%SHADOW% -Ne0.6

REM	------------------------------------------------------------------
REM	Abrir archivo de salida (ps) y establecer variables
rem	gmt psxy -R%REGION3D% -J%PROJ% -JZ%PROZ% -p%p% -T -K -P > %OUT%
	gmt psxy -R%REGION3D% -J%PROJ% -Jz%PROZ% -p%p% -T -K -P > %OUT%

REM	Dibujar Figura
REM	--------------------------------------------------------------------------------------------------------
REM	Bloque 3D. -Qi es para la resolución de la grilla. -BnSwEZ anotaciones según margen (como en la figura 2D)
rem	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT%
rem	gmt grdview %CUT% -R -J -JZ -O -K -p -Qs    -C%color% -I%SHADOW% >> %OUT%
rem	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT% -N%BASE%+glightgray -Wf0.5 -BnSwEZ+b -Bxaf -Byaf -Bzaf+l"Altura (m)" 
	gmt grdview %CUT% -R -J -Jz4c -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT% -BnSwEZ+b -Bxaf -Byaf -Bzaf+l"Altura (m)" 

REM	Pintar Oceanos (-S) y Lineas de Costa
	gmt pscoast -R -J -Jz -O -K -D%D% >> %OUT% -p%p%/0 -Sdodgerblue2 -A0/0/1
	gmt pscoast -R -J -Jz -O -K -D%D% >> %OUT% -p%p%/0 -W1/0.3,black 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -Jz -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
rem	del temp_* gmt*
rem	del %OUT%
	pause
