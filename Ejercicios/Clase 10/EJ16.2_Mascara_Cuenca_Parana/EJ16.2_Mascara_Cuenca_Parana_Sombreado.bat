ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ16.2_Mascara_Cuenca_Parana_Sombreado
	echo %title%

REM	Region: Argentina
	SET	REGION=-70/-42/-36/-12

REM	Proyeccion Mercator (M)
	SET	PROJ=M15c

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	CUT=temp_%title%.grd
	SET	CUT1=temp_%title%_1.grd
	SET	MASK=temp_%title%_mask.grd
	SET	color=temp_%title%.cpt
	SET	color1=temp_%title%_1.cpt
	SET	SHADOW=temp_%title%_shadow.grd
	SET	SHADOW1=temp_%title%_shadow1.grd
	SET	CLIP=temp_clip.txt

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
	gmtset MAP_FRAME_AXES WesN
	gmtset MAP_FRAME_TYPE fancy
	gmtset MAP_FRAME_WIDTH 0.1
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0
	gmtset MAP_SCALE_HEIGHT 0.1618
	gmtset MAP_TICK_LENGTH_PRIMARY 0.1

REM	Sub-seccion PS
	gmtset PS_MEDIA A4

REM	Inicio
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Crear grilla
REM	-------------------------------------------------------------

REM	Recortar la grilla (rectangular)
	gmt grdcut "GMRTv3_3_low.grd" -R -G%CUT1%

REM	Crear/Definir poligono irregular
	SET	CLIP="Cuenca_Parana.txt"
rem	SET	CLIP="Cuenca_Parana.shp"
rem	gmt pscoast -M > %CLIP% -EPY -Df
rem	gmt grdcontour %CUT1% -C+3000 -D%CLIP%
rem	gmt pscoast -R -M > %CLIP% -W1/ -Dh

REM	Crear Mascara Interna. -N:Fuera/Borde/Dentro
	gmt grdmask -R%CUT1% %CLIP% -G%MASK% -NNaN/NaN/1
	gmt grdmath %CUT1% %MASK% MUL = %CUT%

REM	Crear Mapa
REM	-------------------------------------------------------------
REM	Extraer informacion de la grilla recortada para determinar rango de CPT
	gmt grdinfo %CUT%  -T50
	gmt grdinfo %CUT1% -T50
	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
	echo	-5000 	white	6400 	white	> %color1%
	gmt makecpt > %color% -Cdem4 -Z -T0/5700/50

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
	gmt grdgradient %CUT1% -A270 -G%SHADOW1% -Ne0.5
	gmt grdgradient %CUT%  -A270 -G%SHADOW%  -Ne0.5

REM	Crear Imagen a partir de grilla con sombreado y cpt -Q: NaN transparente
	gmt grdimage -R -J -O -K %CUT1% -C%color1% -I%SHADOW1% >> %OUT% 
	gmt grdimage -R -J -O -K %CUT%  -C%color%  -I%SHADOW%  >> %OUT% -Q

REM	Agregar escala de colores a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
	gmt psscale -R -J -O -K -C%color% >> %OUT% -I -DJRM+o0.3c/0+w14/0.618c   -Ba+l"Alturas (km)" -W0.001

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar frame
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf

REM	Dibujar Linea de Costa
	gmt pscoast -R -J -O -K >> %OUT% -Df -W1/0.5

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias, Estados, etc. N3: limites marítimos (Nborder[/pen])
	gmt pscoast -R -J -O -K >> %OUT% -Df -N1/0.30 
	gmt pscoast -R -J -O -K >> %OUT% -Df -N2/0.25,-.

REM	Dibujar CLIP
	gmt psxy -R -J -O -K >> %OUT% %CLIP% -W1,red

REM	Pintar areas húmedas: Oceanos (-S) y Lagos y Rios (-C).
	gmt pscoast -R -J -O -K >> %OUT% -Sdodgerblue2 -C-

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

	del temp_* gmt.* %OUT%

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Probar otros poligonos irregulares para hacer la máscara.
