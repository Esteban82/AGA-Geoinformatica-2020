ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ5.1_Mapa_Topografico_p
	echo %title%

REM	Region: Argentina
	SET	REGION=-72/-64/-35/-30
rem	SET	REGION=-68/-66/-34/-32

REM	Proyeccion Mercator (M)
	SET	PROJ=M15c
	
REM	Perspectiva  (acimut/elevacion)
    	SET    p=180/90
rem    	SET    p=160/30

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

REM	Recortar Grilla
	gmt grdcut "GMRTv3_1.grd" -G%CUT% -R

REM	Extraer informacion de la grilla recortada para determinar rango de CPT
rem	grdinfo %CUT%
	echo Rango de alturas de la grilla (zmin/zmax/dz para makecpt):
	gmt grdinfo %CUT% -T100
	echo Altura grafico (cm):
	gmt mapproject -R -J -Wh
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
	gmt makecpt -Cdem4 -T0/7000/200 > %color% -Z
rem	gmt makecpt -Cdem4 -T0/7000/200 > %color%
rem	gmt makecpt -Cdem3 -T0/7000/100 > %color% -Z
rem	gmt makecpt -Cdem1 -T0/7000/100 > %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT% -G%SHADOW% -Ne0.5 -A270/90
rem	gmt grdgradient %CUT% -G%SHADOW% -Ne0.5 -A90 
rem	gmt grdgradient %CUT% -G%SHADOW% -Ne0.5 -A180
rem	gmt grdgradient %CUT% -G%SHADOW% -Ne0.5 -A270 

REM	Crear Imagen a partir de grilla con sombreado y cpt
rem	gmt grdimage -R -J -O -K "%CUT%" -C%color% -p >> %OUT%
	gmt grdimage -R -J -O -K "%CUT%" -C%color% -p >> %OUT% -I%SHADOW%

REM	Agregar escala de colores a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). Efecto sombreado (-I) 
	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w11/0.618c  -Baf+l"Elevaciones (m)"    -I
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w11/0.618c  -Ba500+l"Elevaciones (m)"  -I
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w8/0.618c   -Baf+l"Elevaciones (m)"    -I
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w-11/0.618c -Baf+l"Elevaciones (m)"    -I
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJBC+o0.35c/0+w11/0.618c  -Baf+l"Elevaciones (km)"   -I -W0.001
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJBC+o0c/0.3+w-15/0.618ch -Baf+l"Elevaciones (km)"   -I -W0.001

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

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

	pause
rem	del temp_* %OUT%
rem 	del gmt.* 

REM	-----------------------------------------------------------------------------------------------------------
REM	Ejercicios Sugeridos:
REM	Probar las otras paleta de Colores (CPT, líneas 64-67). 
REM	1. Utilizar otro cpt maestro para la figura, con otros rangos y con rangos discretos y continuos ().

REM	Efecto Sombreado
REM	2. Modificar el acimut del sol y agregar otro (70-73).

REM	Escala de Colores
REM	3. Probar los otros comandos (80-84). Ver su ubicación, tamaño, orientación. 

REM	Perspectiva.
REM	4. Hacer el mapa la perspectiva de la línea 19. Probar con otra.
	
