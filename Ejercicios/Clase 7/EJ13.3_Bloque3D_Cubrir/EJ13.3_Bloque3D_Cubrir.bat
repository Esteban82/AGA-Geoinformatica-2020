ECHO OFF
cls


REM	Definir Variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ13.3_Bloque3D_Cubrir
	echo %title%

REM	Region: Cuyo
	SET	REGION=-72/-64/-35/-30
	SET	BASE=-10000
	SET	TOP=10000	
	SET	REGION3D=%REGION%/%BASE%/%TOP%

REM	Proyeccion Mercator (M)
	SET	PROJ=M14c

REM	Escala vertical 
	SET	PROZ=4c

REM	Perpesctiva
	SET	p=160/30

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=f

REM 	Nombre archivo de salida y Variables Temporales
	SET	CUT=temp_%title%.grd
	SET	CUT2=temp_%title%_2.grd
	SET	COLOR=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.grd
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
rem	gmt grdcut "GMRTv3_1.grd" -G%CUT% -R%REGION%

REM	Calcular Grilla con modulo del gradiente. Argumento -S para modulo del gradiente (como en ej. 6.1)
rem	gmt grdgradient %CUT% -D -Stemp_mag.grd -R -fg

REM	Convertir modulo del gradiente a inclinacion (pendiente) en radianes (ATAN), y luego a grados (R2D)
rem	gmt grdmath temp_mag.grd ATAN R2D = %CUT2%
	
REM	Informacion Grilla
rem	grdinfo %CUT%
rem	grdinfo %CUT2%
rem	pause

REM	Crear Paleta de Color
rem	gmt makecpt -Cdem4 -T0/7000/250 -Z >%color%
rem	gmt grd2cpt %CUT2% -Crainbow -L0/30 -Z -I -Di >%color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
rem	gmt grdgradient %CUT% -A160 -G%SHADOW% -Ne0.5

REM	Dibujar Figura
REM	--------------------------------------------------------------------------------------------------------
rem	Abrir archivo de salida (ps)
	gmt psxy -R%REGION3D% -J%PROJ% -JZ%PROZ% -p%p% -T -K -P > %OUT%

REM	Bloque 3D. -Qi es para la resolución de la grilla. -BnSwEZ anotaciones según margen (como en la figura 2D). -G es para colocar la grilla por encima de la topografia 
rem	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi30 -C%color% -I%SHADOW% >> %OUT%
rem	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT% -N-10000+glightgray -Wf0.5 
rem	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT% -N-10000+glightgray -Wf0.5 -BnSwEZ+b -Baf -Bzaf+l"Altura (m)" 
	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT% -BnSwEZ+b -Bxaf -Byaf -Bzaf+l"Altura (m)" -G%CUT2%

REM	Pintar Oceanos (-S) y Lineas de Costa
	gmt pscoast -R -J -JZ -O -K -p%p%/0 -D%d% >> %OUT% -Sdodgerblue2 -A0/0/1 
	gmt pscoast -R -J -JZ -O -K -p%p%/0 -D%d% >> %OUT% -W1/0.3,black 

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar Escala al Costado
rem	gmt psscale -R%REGION% -J -O -K -p%p% >> %OUT% -C%color% -I -DJRM+o1.0c/0c+w10/0.618c -Ba+l"Topograf\355a (m)" 
rem	gmt psscale -R%REGION% -J -O -K -p%p% >> %OUT% -C%color% -I -DJRM+o1.0c/0c+w10/0.618c -Ba+l"Pendiente (\232)"  

REM	Dibujar Escala debajo. DJCB para en anclaje por debajo; +o0/1.0c es el offset en x e y; +w 14/0.618c es el largo y ancho de la barra
rem	gmt psscale -R%REGION% -J -O -K -p%p% >> %OUT% -C%color% -I -DJCB+o0/1.0c+w14/0.618ch -Ba+l"Topograf\355a (m)" 
	gmt psscale -R%REGION% -J -O -K -p%p% >> %OUT% -C%color% -I -DJCB+o0/1.0c+w14/0.618ch -Ba+l"Pendiente (\232)"

REM	Dibujar Norte en perspectiva. Td es la rosa; j el anclaje dentro de la figura; TR anclaje respecto al borde superior derecho; +o2/-2.5 offset en X e Y; +w1.25c el tamaño; +f el nivel de las direcciones (f1 es N,S,E y W nomás); l (label) las etiquetas.
rem	gmt psbasemap -R%REGION3D% -J -O -K -JZ -p%p%/%TOP% >> %OUT% -TdjTR+o2/-2.5+w1.25c+f1+lO,E,S,N --FONT_TITLE=8p,4,Black
	gmt psbasemap -R%REGION3D% -J -O -K -JZ -p%p%/%TOP% >> %OUT% -Tg-65/-31+w1.25c+f1+lO,E,S,N --FONT_TITLE=8p,4,Black

REM	Dibujar Escala en perspectiva	
	gmt psbasemap -R%REGION3D% -J -O -K -JZ -p%p%/%BASE% >> %OUT% -Lg-65.5/-33+c-32:30+w100k+f+l 
	
REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -JZ -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
rem	del temp_* gmt.*
	del %OUT%
rem	pause

REM	Ejercicios sugeridos
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Cambiar la ubicación de la escala y del norte en la figura.
REM	2. En esta figura mostramos la grilla de pendientes. Como sería en el caso de un mapa aspecto (orientación de las pendientes)? (Ej 6.2)
