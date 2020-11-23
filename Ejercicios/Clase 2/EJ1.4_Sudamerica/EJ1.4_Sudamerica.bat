ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ1.4_Sudamerica
	echo %title%

REM	Region geografica del mapa (W/E/S/N)
rem	Region: Sudamérica
	SET	REGION=-85/-33/-58/15

rem	Proyeccion Conica. (lon0/lat0/lat1/lat2/width) Proyeccion Albers (B); Lambert (L): Equidistant (D).
rem	SET	PROJ=D-60/-30/-40/0/15c
	SET	PROJ=B-60/-30/-40/0/15c

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros por Defecto
REM	-----------------------------------------------------------------------------------------------------------

REM	Nivel de mensajes. (e)rrores, (w)arnings, (i)nformation
	gmtset GMT_VERBOSE w

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear encabezado del archivo de salida (ps) y setea las variables
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Resaltar paises DCW (AR: Argentina soberana, FK: Malvinas, GS: Georgias del Sur y Sandwich del Sur, CO: Colombia)
	gmt pscoast -R -J -O -K >> %OUT% -EAR,FK,GS+grosybrown2+p 

REM	Pintar areas húmedas: Oceanos (-S) y Lagos (-C+l) o Rios-Lagos (-C+r)
	Set color=117/197/240
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Sdodgerblue2 -C%color%
rem	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Sdodgerblue2 -Cblue+l -Cgreen+r

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias, Estados, etc. N3: limites marítimos (Nborder[/pen])
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -N1/0.75
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -N2/0.25,-.

REM	Dibujar Linea de Costa (level/, where level is 1-4 and represent coastline, lakeshore, island-in-lake shore, and lake-in-island-in-lake shore)
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -W1/0.25

REM	Dibujar rios -Iriver[/pen] 
REM	0 = Double-lined rivers (river-lakes)
REM	1 = Permanent major rivers
REM	2 = Additional major rivers
REM	3 = Additional rivers
REM	4 = Minor rivers
	gmt pscoast -R -J -K -O -D%D% >> %OUT% -I0/thin,%color% 	
	gmt pscoast -R -J -K -O -D%D% >> %OUT% -I1/thinner,%color%
	gmt pscoast -R -J -K -O -D%D% >> %OUT% -I2/thinner,%color%,-
	gmt pscoast -R -J -K -O -D%D% >> %OUT% -I3/thinnest,%color%,-...
	gmt pscoast -R -J -K -O -D%D% >> %OUT% -I4/thinnest,%color%,4_1:0p

REM	Dibujar frame
	gmt psbasemap -R -J -O -K >> %OUT% -Baf 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

rem	pause
	del temp_* gmt.*
	del %OUT%

REM	Ejercicios Sugeridos:
REM     ***********************************************************************
REM	1. Modificar el color de los rios (variable %color%, linea 40).
REM	2. Modificar las lineas de los rios (ancho, estilo de linea) (lineas 57-61)
