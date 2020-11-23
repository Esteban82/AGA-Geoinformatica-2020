ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ6.1_Mapa_Pendiente
	echo %title%

rem	Region: Argentina
	SET	REGION=-72/-64/-35/-30

rem	Proyeccion Mercator (M)
	SET	PROJ=M15c

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM	Perspectiva  (acimut/elevacion)
    	SET	p=180/90

REM	Nivel de Transparencia de 0 (opaco) a 100 (invisible)
	SET	t=40

REM	Variable DEM
	SET	DEM="GMRTv3_1.grd"

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

REM	Calcular grilla de pendientes
REM	*****************************************************************
REM	Calcular grilla con modulo del gradiente
	gmt grdgradient "%DEM%" -D -S"temp_mag.grd" -R -fg

REM   	Convertir modulo del gradiente a inclinacion (pendiente) en radianes (ATAN), y luego a grados (R2D)
	gmt grdmath "temp_mag.grd" ATAN R2D = %CUT%
REM	******************************************************************

REM	Extraer informacion de la grilla recortada para determinar rango de CPT
rem	grdinfo %CUT%
	echo Rango de alturas de la grilla (zmin/zmax/dz para makecpt):
rem	gmt grdinfo %CUT%
rem	gmt grdinfo %CUT% -T2
	echo Altura grafico (cm):
rem	gmt mapproject -R -J -Wh
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z), -Di  Append i to match the colors for the lowest and highest values in the input (instead of the output) CPT file.
rem	gmt makecpt -Crainbow -T0/72/2 -Z -I    > %color%
rem	gmt makecpt -Crainbow -T0/30/2 -Z -I -D > %color%
	gmt makecpt -Cbatlow  -T0/30/2 -Z -I    > %color%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
rem	gmt grdgradient -R "%CUT%" -A270 -G%SHADOW% -Ne0.6
	gmt grdgradient -R "%DEM%" -A270 -G%SHADOW% -Ne0.6

REM	Crear Imagen a partir de grilla con sombreado (-I%SHADOW%)
rem	gmt grdimage -R -J -O -K %CUT% -C%color% -p >> %OUT%
	gmt grdimage -R -J -O -K %CUT% -C%color% -p >> %OUT% -I%SHADOW% 

REM	Agregar curvas de nivel. Equidistancia (-C), Anotaciones (-A). Limitar rango (-Llow/high).
rem	gmt grdcontour -R -J -O -K -p >> %OUT% -t%t% "%DEM%" -C1000 -W0.35,black,-
	gmt grdcontour -R -J -O -K -p >> %OUT% -t%t% "%DEM%" -C2000 -W0.50,black
rem	gmt grdcontour -R -J -O -K -p >> %OUT% -t%t% "%DEM%" -C1000 -W0.50,black   -A2000+u" m"+gwhite

REM	Agregar escala vertical a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda 
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w11.0/0.618c    -Baf+l"Inclinaci\363n pendiente (\232)"
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w10.7/0.618c+e -Baf+l"Inclinaci\363n pendiente (\232)"
	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJRM+o0.35c/0+w10.7/0.618c+ef -Baf+l"Inclinaci\363n pendiente (\232)" -I
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJLM+o0.35c/0                 -Baf+l"Inclinaci\363n pendiente (\232)"

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

REM	Escala en el mapa centrado en el 88% del eje X y 7.5% del eje Y (n), calculado en meridiano (+c), ancho (+w).
	gmt psbasemap -R -J -O -K -p >> %OUT% -Ln0.88/0.075+c-32.5+w100k+f+l   

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

REM	Borrar archivos temporales
rem	del temp_*
	del gmt.* %OUT%
rem	pause

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	Efecto sombreado
REM	1. Agregar el efecto de sombreado (linea 85) calculado a partir del DEM (linea 81) 
REM	2. Hacer lo mismo pero usando la grilla de pendiente para el sombreado (80)
REM
REM	Paleta de Colores
REM	3. Probar los otros comandos (lineas 75-77)
REM	4. Cambiar el valor máximo para la escala de colores (lineas 75-77).

REM	Escala de color
REM	5. Probar las otras escalas de color (lineas 93-95).
REM	6. Probar la escala de color de la linea 96 sin valores de ancho y largo de la escala.
