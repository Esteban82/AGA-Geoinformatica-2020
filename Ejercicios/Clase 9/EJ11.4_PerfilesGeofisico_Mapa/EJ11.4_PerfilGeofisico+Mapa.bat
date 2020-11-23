ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ11.4_PerfilGeofisico+Mapa
	echo %title%

rem	Region: Mar Argentino
	SET	REGION=-80/-40/-45/-28

rem	Proyeccion Mercator (M)
	SET	PROJ=M15c
	
REM	Perfil: Crear archivo para dibujar perfil (Long Lat)
	echo -76 -30 A >  "temp_line"
	echo -46 -40 B >> "temp_line"

REM	Base de datos de GRILLAS
	SET	DEM="GMRTv3_2.grd"
	SET	GRA="grav_29.1.nc"

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	CUT=temp_%title%.nc
	SET	color=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.nc

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

REM	Mapa Base
REM	********************************************************************
REM	Recortar Grilla Topografica
	gmt grdcut %DEM% -G%CUT% -R%REGION%
	gmt grdinfo %CUT% -T50
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
	gmt makecpt -Cbathy -T-8200/0/10 -Z -N >  %color%
	gmt makecpt -Cdem3  -T0/6400/50  -Z    >> %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -A90 -G%SHADOW% -Ne0.6

REM	Crear Imagen a partir de grilla con sombreado
	gmt grdimage -R -J -O -K "%CUT%" -C%color% >> %OUT% -I%SHADOW%

REM	Agregar escala vertical a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
rem	gmt psscale -O -K -Dx15.5/0+w11/0.618c -C%color% -Ba+l"Elevaciones (km)" -I >> %OUT% -W0.001

REM	********************************************************************

REM	Datos Gravimétricos
REM	********************************************************************

REM	Interpolar: agrega datos en el perfil cada 0.2 km (-I). -Ap: lineas sigue paralelo
	gmt sample1d "temp_line" -I0.2k > "temp_sample1d"

REM	Distancia: Agregar columna (3°) con distancia del perfil en km (-G+uk)
	gmt mapproject "temp_sample1d" -G+uk > "temp_track" 

REM	Muestrear grilla (-G) en las posiciones geograficas del perfil. Datos en 4° columna.
	gmt grdtrack "temp_track" -G%GRA% > "temp_data"

REM	Informacion: Ver datos del Archivo para crear el gráfico. 3° Columna datos en KM. 4° Columna datos de Topografia.
	echo N Datos y Min/Max de Long, Lat, Distancia(km) y Anomalies de Aire Libre (mGal):
	gmtinfo "temp_data"
	pause

REM	********************************************************************

REM	Dibujar Perfil
rem	gmt psxy -R -J -O -K "temp_line" -W0.5,black >> %OUT%

REM	Dibujar Perfil con Anomalias
	gmt pswiggle -R -J -O -K "temp_data" -i0,1,3 >> %OUT% -Gred+p -Gblue+n -Z300 -DjRB+o0.1/0.1+w100+lmGal -t50 -T -W

REM	********************************************************************

REM	Dibujar frame
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf 

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -Df >> %OUT% -W1/faint 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

	del temp_* gmt.* %OUT%

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Probar cambiar las coordenadas del perfil (lineas 18, 19)

REM	Perfil de anomalias (linea 97)
REM	2. Cambiar los parametros del perfil que definen el color de las anomalias positivas (-G+p) y negativs (-G+n).
REM	3. Cambiar la escala del perfil (-Z). 
REM	4. Probar de quitar -T y -W.
