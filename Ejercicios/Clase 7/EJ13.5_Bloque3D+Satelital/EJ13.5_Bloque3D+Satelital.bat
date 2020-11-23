ECHO OFF
cls


REM	Definir Variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ13.5_Bloque3D+Satelital
	echo %title%

REM	Region: Cuyo
	SET	REGION=-72/-64/-35/-30
rem	SET	REGION=-70/-66/-34/-32
	SET	REGION3D=%REGION%/-10000/10000
	
REM	Proyeccion Mercator (M)
	SET	PROJ=M14c

REM	Escala vertical 
	SET	PROZ=4c

REM	Perpesctiva
	SET	p=160/30

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=f

REM 	Nombre archivo de salida y Variables Temporales
	SET	CUT=temp_%title%.nc
	SET	CUT2=temp_%title%_2.nc
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

REM	Dibujar Figura
REM	--------------------------------------------------------------------------------------------------------
rem	Abrir archivo de salida (ps)
	gmt psxy -R%REGION3D% -J%PROJ% -JZ%PROZ% -p%p% -T -K -P > %OUT%

REM	Bloque 3D.
	gmt grdview %CUT% -R -J -JZ -O -K -p -Qi300 >> %OUT% -G"Imagen_Geo.tif" -BnSwEZ+b -Baf -Bzaf+l"Altura (m)"

REM	Pintar Oceanos (-S) y Lineas de Costa (z = 0).
rem	gmt pscoast -R -J -JZ -O -K -p%p%/0 -D%d% >> %OUT% -Sdodgerblue2 -A0/0/1
	gmt pscoast -R -J -JZ -O -K -p%p%/0 -D%d% >> %OUT% -W1/0.3,black 

REM	Dibujar datos de pscoast en 3D. -M grdtrack muestrea la grilla en localizaciones específicas de X e Y. 
	gmt pscoast -R%REGION% -D%d% -M -N1/ | grdtrack -G%CUT% -sa | psxyz -R%REGION3D% -J -JZ -O -K -p >> %OUT% -W0.5,black 
		
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
REM	Dibujar Norte en perspectiva
	gmt psbasemap -R%REGION% -J -O -K -p%p% >> %OUT% -TdjTR+o2/-2.5+w1.25c+f1+lO,E,S,N --FONT_TITLE=8p,4,Black

REM	Dibujar Escala en perspectiva	
	gmt psbasemap -R%REGION% -J -O -K -p%p% >> %OUT% -Lg-65.5/-33+c-32:30+w100k+f+l 
	
REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -JZ -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp_* gmt.*
	del %OUT%
	pause

REM	Ejercicios sugeridos
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Probar la exageración vertical de la topografía, y observar como se ajustan los datos vectoriales.
REM	2. Agregar nuevos datos culturales (Variar los trazos y color de relleno de los datos del IGN.
REM	3. Probar agregar símbolos para los datos de puntos de asentamientos y localidades.
