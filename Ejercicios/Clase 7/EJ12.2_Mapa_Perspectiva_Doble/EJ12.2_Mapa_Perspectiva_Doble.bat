ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ12.2_Mapa_Perspectiva_Doble
	echo %title%

REM	Region: Cuyo
	SET	REGION=-72/-64/-35/-30
rem	SET	REGION=-71/-68/-33/-31

REM	Proyeccion: Mercator (M)
	SET	PROJ=M15c
	
REM	Perspectiva  (acimut/elevacion)
	SET	p=160/30

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

REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P -p%p% > %OUT%

REM	Dibujar mapa 1 
REM	-----------------------------------------------------------------------------------------------------------
REM	Recortar Grilla
	gmt grdcut "GMRTv3_1.grd" -G%CUT% -R

rem	grdinfo %CUT%

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
	gmt makecpt -Cdem4 -T0/7000/250 -Z > %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -A270 -G%SHADOW% -Ne0.5

REM	Crear Imagen a partir de grilla con sombreado
	gmt grdimage -R -J -O -K %CUT% -C%color% >> %OUT% -I%SHADOW% -p 

REM	Agregar escala vertical a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
	gmt psscale -R -J -O -K -p  >> %OUT% -DJRM+o0.3c/0+w11/0.618c -C%color% -Ba+l"Elevaciones (km)" -I -W0.001

REM	Datos Instituto Geografico Nacional (IGN)
REM	-----------------------------------------------------------------------------------------------------------
REM	Limites Interprovincial
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\linea_de_limite_070111.shp" -Wthinner,black,-.

REM 	Red vial y ferroviaria
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Autopista.gmt"        -Wthinner,black
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Ruta_Nacional.gmt"    -Wthinner,black
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\lineas_de_transporte_ferroviario_AN010.shp"      -Wthinnest,darkred
	
REM	Localidades y Areas Urbanas
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\puntos_de_asentamientos_y_edificios_localidad.shp" -Sc0.08 -Ggray19
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\areas_de_asentamientos_y_edificios_020105.shp"     -Wfaint -Ggreen

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar frame
	gmt psbasemap -R -J -O -K -p >> %OUT% -Bxaf -Byaf

REM	Pintar areas húmedas: Oceanos (-S) y Lagos (-Cl/)f
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -Sdodgerblue2 -A0/0/1

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias/Estados.
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -N1/0.75

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -W1/faint 

REM	***********************************************************************************************************
REM	Transicion Mapa 1-2. Desplazamiento en eje Y (del grafico).
	gmt psxy -R -J -O -K -p -T >> %OUT% -Y7.5c
REM	***********************************************************************************************************

REM	Dibujar mapa 2
REM	-----------------------------------------------------------------------------------------------------------
REM	Graficar Imagen satelital
rem	gmt grdimage -R -J -O -K -p >> %OUT% "Imagen_Geo.tif"
	gmt grdimage -R -J -O -K -p >> %OUT% "Imagen_Geo.tif" -I%SHADOW%

REM	Datos Instituto Geografico Nacional (IGN)
REM	-----------------------------------------------------------------------------------------------------------
REM	Limites Interprovincial
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\linea_de_limite_070111.shp" -Wthinner,black,-.

REM 	Red vial y ferroviaria
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Autopista.gmt"        -Wthinner,black
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Ruta_Nacional.gmt"    -Wthinner,black
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\lineas_de_transporte_ferroviario_AN010.shp"      -Wthinnest,darkred
	
REM	Localidades y Areas Urbanas
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\puntos_de_asentamientos_y_edificios_localidad.shp" -Sc0.08 -Ggray19
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\areas_de_asentamientos_y_edificios_020105.shp"     -Wfaint -Ggreen

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar frame
	gmt psbasemap -R -J -O -K -p >> %OUT% -Bxaf -Byaf

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias/Estados.
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -N1/0.75

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -W1/faint 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

rem	pause
REM	Borrar archivos temporales
	del temp_* gmt.* %OUT%

REM	Ejercicios sugeridos
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Cambiar la perspectiva de los mapas (linea 19) y ajustar la distancia entre los 2 mapas (linea 96) para que no superpongan.
REM	2. Probar sin perpesctiva (p=180/90).
