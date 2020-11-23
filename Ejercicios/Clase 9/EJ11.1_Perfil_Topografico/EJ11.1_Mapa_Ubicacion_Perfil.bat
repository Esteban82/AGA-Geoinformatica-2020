ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ11.1_Mapa_Ubicacion_Perfil
	echo %title%

REM	Definir Grilla
	SET	DEM=GMRTv3_2.grd

rem	Region: Mar Argentino
	SET	REGION=-80/-40/-45/-28

rem	Proyeccion Mercator (M)
	SET	PROJ=M15c

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

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
rem	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Recortar Grilla
	grdcut %DEM% -G%CUT% -R%REGION%
	grdinfo %CUT% -T100
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
	gmt makecpt -Cbathy -T-8200/0/10 -Z -N >  %color%
	gmt makecpt -Cdem3  -T0/6400/50  -Z    >> %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -A90 -G%SHADOW% -Ne0.5

REM	Crear Imagen a partir de grilla con sombreado y cpt
	gmt grdimage -R -J -O -K %CUT% -C%color% >> %OUT% -I%SHADOW%

REM	Agregar escala de colores a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
	gmt psscale -R -J -O -K -DJRM+o0.3c/0+w8/0.618c -C%color% -Bag+l"Elevaciones (km)"  -I >> %OUT% -W0.001

REM	Dibujar frame
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -D%d% >> %OUT% -W1/faint

REM	Perfil: Crear archivo para dibujar perfil (Long Lat)
	echo -76 -30 A >  "temp_line"
	echo -46 -40 B >> "temp_line"

REM	Dibujar Pefil
	gmt psxy -R -J -O -K >> %OUT% "temp_line" -W1,red

REM	Dibujar Letras del Perfil
	gmt pstext -R -J -O -K >> %OUT% "temp_line" -Dx0c/0.3c

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

REM	Borrar temporales
	del temp_* %OUT%
	del gmt.*

rem	pause
