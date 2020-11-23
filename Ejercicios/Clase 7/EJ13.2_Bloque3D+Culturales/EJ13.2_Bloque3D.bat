ECHO OFF
cls


REM	Definir Variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ13.2_Bloque3D
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
	gmt grdcut "GMRTv3_1.grd" -G%CUT% -R%REGION%

REM	Informacion Grilla
	grdinfo %CUT%
rem	pause

REM	Crear Paleta de Color
	gmt makecpt -Cdem4 -T0/7000/250 -Z >%color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -A160 -G%SHADOW% -Ne0.5

REM	Dibujar Figura
REM	--------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION3D% -J%PROJ% -JZ%PROZ% -p%p% -T -K -P > %OUT%

REM	Bloque 3D. 
	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 -C%color% -I%SHADOW% >> %OUT% -Wf0.5 -BnSwEZ+b -Baf -Bzaf+l"Altura (m)" 

REM	Dibujar datos culturales en bloque 3D
REM	-----------------------------------------------------------------------------------------------------------
REM	Pintar Oceanos (-S) y Lineas de Costa en 2D
rem	gmt psxy -R%REGION3D% -J%PROJ% -JZ%PROZ% -p%p% -T -K -P >> %OUT%
	gmt pscoast -R -J -JZ -O -K -p%p%/0 -D%d% >> %OUT% -Sdodgerblue2 -A0/0/1 
	gmt pscoast -R -J -JZ -O -K -p%p%/0 -D%d% >> %OUT% -W1/0.3,black 
	
REM	Dibujar datos de pscoast en 3D
	gmt pscoast -R%REGION% -Df -M -N1/ | grdtrack -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -W0.5,black 

REM	Datos Instituto Geografico Nacional (IGN)
REM	-----------------------------------------------------------------------------------------------------------
REM	Limites Interprovincial
	gmt grdtrack -R%REGION% "Datos\linea_de_limite_070111.shp" -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -Wthinner,black,-.

REM 	Red vial y ferroviaria
	gmt grdtrack -R%REGION%	"Datos\RedVial_Autopista.gmt" -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -Wthinner,black
	gmt grdtrack -R%REGION%	"Datos\RedVial_Ruta_Nacional.gmt" -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -Wthinner,black
	gmt grdtrack -R%REGION%	"Datos\lineas_de_transporte_ferroviario_AN010.shp" -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -Wthinnest,darkred

REM	Localidades y Areas Urbanas
	gmt grdtrack -R%REGION% "Datos\puntos_de_asentamientos_y_edificios_localidad.shp" -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -Sc0.08 -Ggray19
	gmt grdtrack -R%REGION% "Datos\areas_de_asentamientos_y_edificios_020105.shp"     -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -Wfaint -Ggreen


REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -JZ -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp_* gmt.* %OUT%
rem	pause
