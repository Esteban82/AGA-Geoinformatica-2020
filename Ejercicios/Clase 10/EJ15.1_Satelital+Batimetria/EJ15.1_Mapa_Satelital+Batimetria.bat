ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ15.1_Mapa_Satelital+Batimetria
	echo %title%
 
rem	Region Geografica
	SET	REGION=-78/-18/-56/-29

rem	Proyeccion Cilindrica: (M)ercator y Ancho de la figura (W) 
	SET	PROJ=M15c

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	CUT=temp_%title%.grd
	SET	color=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.grd

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

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Seleccionar resolucion de la imagen satelital: 01d, 30m, 20m, 15m, 10m, 06m, 05m, 04m, 03m, 02m, 01m, 30s
	SET 	RES=03m

REM	Graficar Imagen Satelital BlueMarble (day) o BlackMarble (night)
	gmt grdimage -R -J -O -K >> %OUT% "@earth_day_%RES%"

REM	Recortar Grilla
	gmt grdcut "GMRTv3_2.grd" -G%CUT% -R%REGION%

REM	Informacion grilla para cpt
	grdinfo %CUT% -T50
	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
rem	gmt makecpt -Cibcso -Z > %color%
	gmt makecpt -Cdem4  -Z > %color% -T0/6500

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -A90 -G%SHADOW% -Ne0.5

REM	Recorte de la grilla por linea de la costa
REM	***********************************************************************
REM	Iniciar recorte siguiendo la linea de costa para areas húmedeas (-S) o secas (-G)
	gmt pscoast -R -J -O -K >> %OUT% -Df -S -A0/0/1
rem	gmt pscoast -R -J -O -K >> %OUT% -Df -G -A0/0/1

REM	Dibujar imagen a partir de la grilla
	gmt grdimage -R -J -O -K %CUT% >> %OUT% -C%color% -I%SHADOW%

REM	Finalizar recorte siguiendo la linea de costa (-Q)
	gmt pscoast -R -J -K -O >> %OUT% -Q
REM	***********************************************************************

REM	Agregar escala vertical a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
rem	gmt psscale -R -J -O -K -C%color% >> %OUT% -Dx15.3/0+w9.3/0.618c -Ba+l"Profundidad (km)"  -I -W0.001
	gmt psscale -R -J -O -K -C%color% >> %OUT% -Dx15.3/0+w9.3/0.618c -Ba+l"Alturas (km)"      -I -W0.001

REM	Dibujar Linea de Costa
	gmt pscoast -R -J -O -K >> %OUT% -Df -W1/thinnest

REM	Dibujar frame (-B): Anotaciones (a), frame (f), grilla (g). Opcionalmete agregar valores.
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t). 
	gmt psconvert %OUT% -A -Tg

REM	Borrar temporales
	del temp_* gmt.* 
rem	del %OUT%
	pause
