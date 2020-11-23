ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=Mapa_SRTM
	echo %title%

REM	Grilla SRTM
	SET	DEM="S49W069.hgt"

REM	Region: Argentina
	SET	REGION=%DEM%

REM	Proyeccion Mercator (M)
	SET	PROJ=M15c
	
REM	Perspectiva  (acimut/elevacion)
    	SET    p=180/90

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
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT% -p%p%

REM	Convertir hgt a grilla
	gmt xyz2grd %DEM% -I3c -ZTLhw -G%CUT% -N-32768 -R%DEM%
rem	gmt xyz2grd S49W069.hgt -I3c -ZTLhw -GDEM.nc -N-32768 -RS49W069.hgt

REM	Informacion Grilla
	gmt grdinfo %DEM%
	pause	
	gmt grdinfo %CUT%
	pause

REM	Extraer informacion de la grilla recortada para determinar rango de CPT
rem	grdinfo %CUT%
	echo Rango de alturas de la grilla (zmin/zmax/dz para makecpt):
	gmt grdinfo %CUT% -T10
	echo Altura grafico (cm):
	gmt mapproject -R -J -Wh
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
	gmt makecpt -Cdem1 -T0/2000/10 > %color% -Z

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -G%SHADOW% -Ne0.7 -A90

REM	Crear Imagen a partir de grilla con sombreado y cpt
	gmt grdimage -R -J -O -K "%CUT%" -C%color% -p >> %OUT% -I%SHADOW%

REM	Agregar escala de colores a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). Efecto sombreado (-I) 
	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0   -Baf+l"Elevaciones (m)"    -I

REM	Dibujar frame
	gmt psbasemap -R -J -O -K -p >> %OUT% -Bxaf -Byaf

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

rem	pause
REM	Borrar temporales
	del temp_* %OUT%
 	del gmt.* 
