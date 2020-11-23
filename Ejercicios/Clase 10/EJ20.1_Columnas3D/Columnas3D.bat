ECHO OFF
cls


REM	Definir Variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=Columnas3D
	echo %title%

REM	Region: Cuyo
	SET	REGION=-85/-33/-58/15
	SET	REGION3D=%REGION%/0/15

REM	Proyeccion Mercator (M)
	SET	PROJ=M15c
	SET	PROZ=5c
	SET	persp=210/40

REM 	Nombre archivo de salida y Variables Temporales
	SET	COLOR=temp_%title%.cpt
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
	gmt pscoast -R -J -O -K -JZ -p >> %OUT% -Df -N1 

REM	Dibujar Ejes Longitud y Latitud
	gmt psbasemap -R -J -JZ -O -K -p >> %OUT% -BWSneZ -Ba

REM	-----------------------------------------------------------------------------
REM	Titulo
	gmt psbasemap -R -J -JZ -O -K -p >> %OUT% -B+t"Copas Am\351ricas Ganadas"

REM	Eje Z
	gmt psbasemap -R -J -JZ -O -K -p >> %OUT% -BWSneZ+b  -Bzafg+l"Cantidad"

REM	Info Columnas
	gmtinfo "CopaAmerica.csv" -T1+c2
	gmtinfo "CopaAmerica.csv" -T1+c3
rem	pause

REM	Crear CPT
rem	gmt makecpt -Crainbow     -T0/16/1  > %color%
	gmt makecpt -Crainbow     -T18/45/1 > %color%

REM	Dibujar Datos en Columnas 
rem	gmt psxyz -R -J -JZ -O -K -p >> %OUT% "CopaAmerica.csv" -So0.5c -Wthinner -Gblue    -i0,1,2
rem	gmt psxyz -R -J -JZ -O -K -p >> %OUT% "CopaAmerica.csv" -So0.5c -Wthinner -C%color% -i0,1,2,2
	gmt psxyz -R -J -JZ -O -K -p >> %OUT% "CopaAmerica.csv" -So0.5c -Wthinner -C%color% -i0,1,2,3

REM	Escribir Numero 
	gmt convert "CopaAmerica.csv" -o0,1,2 | gmt pstext -R%REGION% -J -O -K -p -Gwhite@30 -D0/-0.8c -F+f20p,Helvetica-Bold,firebrick=thinner+jCM >> %OUT%

REM	Dibujar CPT
REM	-----------------------------------------------------------------------------

rem	gmt psscale -R -J -JZ -O -K -p -C%color% >> %OUT% -DJRM+o0.3c/0+w13/0.618c -L0.1 -B+l"Cantidad"
	gmt psscale -R -J -JZ -O -K -p -C%color% >> %OUT% -DJRM+o0.3c/0+w13/0.618c -L0.1 -B+l"Participaciones" 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -JZ -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp_* gmt.* %OUT%
rem	pause
