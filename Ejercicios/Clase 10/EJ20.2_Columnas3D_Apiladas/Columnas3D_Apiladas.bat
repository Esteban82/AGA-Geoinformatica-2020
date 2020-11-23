ECHO OFF
cls


REM	Definir Variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=Columnas3D_Apiladas
	echo %title%

REM	Region
	SET	REGION=-85/-33/-58/15
	SET	REGION3D=%REGION%/0/35

REM	Proyeccion Mercator (M)
	SET	PROJ=M15c
	SET	PROZ=5c
	SET	persp=210/40

REM	Nombre archivo de entrada
	SET	INPUT="CopaAmerica.csv"

REM 	Nombre archivo de salida y Variables Temporales
	SET	CUT=temp_%title%.grd
	SET	COLOR=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.grd
	SET	OUT=%title%.ps  

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

REM	Dibujar Figura
REM	--------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION3D% -J%PROJ% -JZ%PROZ% -p%persp% -T -K -P > %OUT%

REM	Pintar areas secas (-G). Resolucion datos full (-Df)
	gmt pscoast -R -J -O -K -JZ -p >> %OUT% -Df -G200 

REM	Pintar areas húmedas: Oceanos (-S) y Lagos y Rios (-C).
	gmt pscoast -R -J -O -K -JZ -p >> %OUT% -Sdodgerblue2 -C200 -Df

REM	Dibujar Paises (1 paises, 2 estados/provincias en America, 3 limite maritimo)
	gmt pscoast -R -J -JZ -O -K -p -Df >> %OUT% -N1

REM	Dibujar Ejes Longitud y Latitud
	gmt psbasemap -R -J -JZ -O -K -p >> %OUT% -BWSneZ -Ba

REM	-----------------------------------------------------------------------------
REM	Titulo
	gmt psbasemap -R -J -JZ -O -K -p >> %OUT% -B+t"Copas Am\351ricas Ganadas"

REM	Eje Z
	gmt psbasemap -R -J -JZ -O -K -p >> %OUT% -BWSneZ+b  -Bzafg+l"Cantidad"


REM	Dibujar Datos en Columnas Apiladas
REM	----------------------------------------------
	gmt psxyz -R -J -JZ -O -K -p >> %OUT% %INPUT% -So0.5c  -Gblue   -Wthinner -i0,1,2
	gmt psxyz -R -J -JZ -O -K -p >> %OUT% %INPUT% -So0.5cb -Ggreen  -Wthinner -i0,1,6,2
	gmt psxyz -R -J -JZ -O -K -p >> %OUT% %INPUT% -So0.5cb -Gyellow -Wthinner -i0,1,7,6
	gmt psxyz -R -J -JZ -O -K -p >> %OUT% %INPUT% -So0.5cb -Gred    -Wthinner -i0,1,8,7

REM	Escribir Numero Total
	gmt convert %INPUT% -o0,1,8 | gmt pstext -R%REGION% -J -O -K -p -Gwhite@30 -D0/-0.8c -F+f20p,Helvetica-Bold,firebrick=thinner+jCM >> %OUT%

REM	Leyenda
REM	----------------------------------------------------------------------------

REM	Archivo auxiliar leyenda
 	echo H 10 Times-Roman Copas Am\351ricas > "temp_leyenda"
	echo N 1 >> "temp_leyenda"
 	echo S 0.25c r 0.5c blue   0.25p 0.75c 1 Puesto	 >> "temp_leyenda"
 	echo S 0.25c r 0.5c green  0.25p 0.75c 2 Puesto	 >> "temp_leyenda"
 	echo S 0.25c r 0.5c yellow 0.25p 0.75c 3 Puesto	 >> "temp_leyenda"
 	echo S 0.25c r 0.5c red    0.25p 0.75c 4 Puesto	 >> "temp_leyenda"

REM	Dibujar leyenda	
	gmt pslegend -R -J -JZ -O -K -p >> %OUT% "temp_leyenda" -DjLB+o0.2i+w1.35i/0+jBL -F+glightgrey+pthinner+s-4p/-6p/grey20@40

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -JZ -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del gmt.* temp_* %OUT%
