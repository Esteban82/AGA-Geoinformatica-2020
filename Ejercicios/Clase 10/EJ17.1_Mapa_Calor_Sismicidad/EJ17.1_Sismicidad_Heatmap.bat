ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ17.1_Sismicidad_Heatmap
	echo %title%
 
REM	Region Geografica
	SET	REGION=-79/-20/-63/-20
REM	Region Cuyo
rem	SET	REGION=-76/-60/-38/-26

REM	Resolucion: 01d, 30m, 20m, 15m, 10m, 06m, 05m, 04m, 03m, 02m, 01m, 30s
	SET	RES=03m

REM	Proyeccion Cilindrica: (M)ercator
	SET	PROJ=M15c

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	CUT=temp_%title%.grd
	SET	CUT2=temp_%title%2.grd
	SET	color=temp_%title%.cpt
	SET	color2=temp_%title%2.cpt
	SET	SHADOW=temp_%title%_shadow.grd

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

REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A). 
	gmt grdgradient "@earth_relief_%RES%" -Ne0.6 -A270 -G"%SHADOW%"

REM	Crear CPT Mapa Fondo 
	gmt makecpt -T-11000,0,9000 -Cdodgerblue2,white > %color%

REM	Dibujar Mapa Base
REM	--------------------------------------------------
REM	Crear Imagen a partir de grilla con sombreado
	gmt grdimage -R -J -O -K "@earth_relief_%RES%" -C%color% -I%SHADOW% >> %OUT%

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias, Estados, etc. N3: limites marítimos (Nborder[/pen])
	gmt pscoast -R -J -O -K >> %OUT% -Df -N1/0.30 
	gmt pscoast -R -J -O -K >> %OUT% -Df -N2/0.25,-.

REM	Dibujar Linea de Costa
	gmt pscoast -R -J -O -K >> %OUT% -Df -W1/faint 

REM	Procesar Sismos
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear archivo con datos para heatmap
	SET	res=10k

REM	Procesar Sismos. Contar cantidad de sismos en bloques de %res% de lado.
	gmt blockmean -R "Sismos_Input\query_*.csv" -Sn -C -h1 -i2,1 > "temp_Heatmap.xyz" -I%res%

REM	Crear grilla de cantidad de datos por bloque (densidad de datos, heatmap)
	gmt xyz2grd -R -G%CUT2% "temp_Heatmap.xyz" -I%res%

REM	Analisis de datos
	gmt pshistogram "temp_Heatmap.xyz" -W10 -Io -i2 -Z0
	grdinfo %CUT2% -T5
	grdinfo %CUT2% -T5+a1
	grdinfo %CUT2% -T5+a2.5
	grdinfo %CUT2% -T5+a5
	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
	gmt grd2cpt %CUT2% > %color2% -Z -Di -Chot -L1/30

REM	Crear Imagen a partir de grilla con sombreado y cpt. -Q transparente las zonas sin datos. 
	gmt grdimage -R -J -O -K %CUT2% -C%color2% >> %OUT% -Q -t25

REM	Agregar escala de colores a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
	gmt psscale -R -J -O -K -C%color2% >> %OUT% -DjRT+o1.7c/0.7+w9/0.618c+ef -Baf+l"Cantidad de Sismos cada 100 km@+2@+"  -F+gwhite+p+i+s

REM	Terminar de Dibujar Mapa Base
REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar Escala centrado en -Ln(%/%), unidad arriba de escala (+l), unidad con los valores (+u)
	gmt psbasemap -R -J -O -K >> %OUT% -Ln0.11/0.075+c-32:00+w800k+f+l -F+gwhite+p+i+s

REM	Dibujar frame (-B): Anotaciones (a), frame (f), grilla (g)
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

	del temp_* gmt.* %OUT%
rem	pause
