ECHO OFF
cls
 
REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ7.3_Mapa_Grav_Bouguer
	echo %title%

REM	Region: Sudamerica y Atlantico Sur
rem	SET	REGION=-78/-18/-60/-20
	SET	REGION=282/342/-60/-20

REM	Proyeccion Mercator (M)
	SET	PROJ=M15c
			
REM	Perspectiva  (acimut/elevacion)
    	SET    p=180/90
rem    	SET    p=160/30

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

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
	
REM	Editar Datos
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P -p%p% > %OUT%

REM	Crear grilla a partir de tabla de formato gdf. Stepgrid (-I). Lineas de encabezado (-h).
	gmt xyz2grd -R -G%CUT% "eigen-6c4*.gdf" -h37 -I0.1
	
rem	grdinfo %CUT%
	grdinfo %CUT% -T50
	pause

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
rem	gmt makecpt -T-550/450/50 -Z > %color%
rem	gmt grd2cpt %CUT% -Z > %color%
	gmt grd2cpt %CUT% -Z -L-150/150 -D > %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -A0/270 -G%SHADOW% -Ne0.5

REM	Crear Imagen a partir de grilla con  paleta de colores y sombreado
	gmt grdimage -R -J -O -K -p >> %OUT% "%CUT%" -C%color% -I%SHADOW%

REM	Agrega escala de colores. (-E triangles). Posición (-D) (horizontal = h)
	gmt psscale -R -J -O -K -p  >> %OUT% -I -C%color% -Dx15.5/0.3+w13.1/0.618c+e -Ba10+l"Anomal\355as Bouguer (mGal)" 

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

REM	Curvas de nivel 2. -L: Limita valores minimo y máximo. -T: Agrega marcas en max y min. 
	gmt grdcontour -R -J -O -K -p >> %OUT% "%CUT%" -C30 -L-150/150        -W0.4,61 -T0.1i/0.02i:-+ -A+d+f6 
rem	gmt grdcontour -R -J -O -K -p >> %OUT% "%CUT%" -C30 -L-150/150 -Q100k -W0.4,61 -T0.1i/0.02i:-+ -A+d+f6 

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar frame
	gmt psbasemap -R -J -O -K -p >> %OUT% -Bxaf -Byaf
	
REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias/Estados.
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -N1/0.75

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -W1/thin

REM	Escala del mapa centrado (n) en el 88% del eje X y 7.5% del eje Y, calculado en meridiano (+c), ancho (+w). 
	gmt psbasemap -R -J -O -K -p >> %OUT% -Ln0.08/0.075+c-32:00+w800k+f+l

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	psconvert %OUT% -Tg -A

REM	Borrar Archivos temporales
	del temp_* gmt.* %OUT%
	
REM	Ejercicios Sugeridos:
REM	----------------------------------------------------------------------------------------------------------
REM	1. Reubicar la escala usando valores normalizados (linea 104).
REM	
REM	Curvas de nivel:
REM	2. Cambiar valores minimo y maximo para dibujarlas (-L en linea 90).
REM	3. Cambiar valores de Q (linea 91) para NO dibujar curvas de nivel más pequeñas a X km.
REM
REM	Creacion de paleta de colores (CPT):
REM	4. Probar los otros comandos para crearlas (lineas 62, 63).
REM	5. Cambiar los valores mínimo y máximo para crear el CPT (-L en linea 64).
