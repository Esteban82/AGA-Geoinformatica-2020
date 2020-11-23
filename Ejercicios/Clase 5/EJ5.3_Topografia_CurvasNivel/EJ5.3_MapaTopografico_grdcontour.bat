ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ5.3_MapaTopografico_grdcontour
	echo %title%

rem	Region: Argentina
rem	SET	REGION=-72/-64/-35/-30
	SET	REGION=-70:10/-69:45/-32:50/-32:30

rem	Proyeccion Mercator (M)
	SET	PROJ=M15c

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM	Perspectiva  (acimut/elevacion)
    	SET    p=180/90

REM	Nivel de Transparencia de 0 (opaco) a 100 (invisible)
	SET	t=60

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

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
rem	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT% -p%p%

REM	Recortar Grilla
rem	gmt grdcut "GMRTv3_1.grd" -G%CUT% -R

REM	Extraer informacion de la grilla recortada para determinar rango de CPT
rem	grdinfo %CUT%
	gmt grdinfo %CUT% -T10
	echo Altura grafico (cm):
	gmt mapproject -R -J -Wh
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
rem	gmt makecpt -Cdem4 -T0/7000/250 > %color%
	gmt makecpt -Cdem4 -T0/7000 -Z > %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
rem	gmt grdgradient %CUT% -A270 -G%SHADOW% -Ne0.6

REM	Crear Imagen a partir de grilla con sombreado
rem	gmt grdimage -R -J -O -K "%CUT%" -C%color% -p >> %OUT%
	gmt grdimage -R -J -O -K "%CUT%" -C%color% -p >> %OUT% -I%SHADOW%

REM	Agregar escala de colores a partir de CPT (-C). +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w11.00/0.618c -I -Baf+l"Elevaciones (m)" -W0.001
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w14.18/0.618c -I -Baf+l"Elevaciones (m)" -W0.001

REM	Agregar curvas de nivel. Equidistancia (-C), Anotaciones (-A).
rem	gmt grdcontour -R -J -O -K -p >> %OUT% -t%t% "%CUT%" -C100  -W0.35,black,- 
rem	gmt grdcontour -R -J -O -K -p >> %OUT% -t%t% "%CUT%" -C1000 -W0.50,black
rem	gmt grdcontour -R -J -O -K -p >> %OUT% -t%t% "%CUT%" -C500 -W0.50,black   -A2000+u" m"
	gmt grdcontour -R -J -O -K -p >> %OUT% -t%t% "%CUT%" -C1000 -W0.50,black   -A2000+u" m"+gwhite+f6

REM	Datos Instituto Geografico Nacional (IGN)
REM	-----------------------------------------------------------------------------------------------------------
REM	Limites Interprovincial
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\linea_de_limite_070111.shp" -Wthinner,black,-.

REM 	Red vial y ferroviaria
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Autopista.gmt"        -Wthinner,blue
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Ruta_Nacional.gmt"    -Wthinner,blue
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\lineas_de_transporte_ferroviario_AN010.shp"      -Wthinnest,darkred
	
REM	Localidades y Areas Urbanas. 
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\puntos_de_asentamientos_y_edificios_localidad.shp" -Sc0.08 -Ggray19
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\areas_de_asentamientos_y_edificios_020105.shp"     -Wfaint -Gdarkgray

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar frame
	gmt psbasemap -R -J -O -K -p >> %OUT% -Bxaf -Byaf

REM	Pintar areas húmedas: Oceanos (-S) y Lagos (-C+l)
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -Sdodgerblue2 -A0/0/1

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias/Estados.
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -N1/1,white,solid

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -W1/faint 

REM	Dibujar escala calculada en meridiano (+c), ancho (+w), unidad arriba de escala (+l)
	gmt psbasemap -R -J -O -K >> %OUT% -Ln0.87/0.0759+c-32:40+w5k+f+l 
	gmt psbasemap -R -J -O -K >> %OUT% -Ln0.27/0.0759+c-32:40+w5000e+f+l 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

REM	Borrar archivos temporales
rem	del temp_* gmt.* 
rem	del %OUT%

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	Curvas de Nivel
REM	1. Cambiar los intervalos de las curvas secundarias (línea 77) y primarias (línea 82).
REM	2. Cambiar el intervalo de las anotaciones (-A en línea 82).
REM	3. Cambiar la transparencia de las curvas de nivel (-t, linea 30).
REM	4. Pasar la escala de km a m (usar linea 113).
REM	5. Ajustar el largo de la escala a la altura del mapa (linea 76).
