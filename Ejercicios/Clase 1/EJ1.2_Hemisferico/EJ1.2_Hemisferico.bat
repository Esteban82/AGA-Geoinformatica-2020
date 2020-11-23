ECHO OFF
cls


REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ1.2_Hemisferico_-C-
	echo %title%

REM	Proyecciones acimutales requieren 3 parametros + 1 opcional (lon0/lat0[/horizon]/width
REM	L(a)mbert Equal Area; (S)tereographic; Orto(g)rafica; (E)quidistante
	SET	PROJ=G-65/-30/90/15c
rem	SET	PROJ=S-65/-30/30/15c
	SET	PROJ=S37.617778/55.755833/30/15c
 
REM	Region geografica del mapa (W/E/S/N) d=-180/180/-90/90 g=0/360/-90/90
	SET	REGION=d

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

REM	Resolucion de Blue/Black Marble: 01d, 30m, 20m, 15m, 10m, 06m, 05m, 04m, 03m, 02m, 01m, 30s
	SET	RES=02m
	gmt grdimage -R -J -O -K >> %OUT% "@earth_day_%RES%"

REM	Pintar areas secas (-Gcolor). -D: Resolucion datos
	gmt pscoast -R -J -O -K >> %OUT% -D%D% -G200

	gmt pscoast -R -J -O -K >> %OUT% -E=AN+gpurple+p

REM	Dibujar Antartida Argentina (entre 74° y 25° Oeste, y entre 60° Sur y el polo Sur).
REM	Crear archivo con coordendas
	echo -74 -60 >  "temp_Antartida_Argentina"
	echo -74 -90 >> "temp_Antartida_Argentina"
	echo -25 -60 >> "temp_Antartida_Argentina"

REM	Dibujar archivo previo. Borde (-Wpen), Relleno (-Gfill), Lineas siguen meridianos (-Am), Cerrar polígonos (-L)
rem	gmt psxy -R -J -O -K "temp_Antartida_Argentina" >> %OUT% -L -Am -Grosybrown2 -W0.25

REM	Pintar areas húmedas: Oceanos (-S) y Lagos y Rios (-C).
rem	gmt pscoast -R -J -O -K >> %OUT% -D%D% -Sdodgerblue2
rem	gmt pscoast -R -J -O -K >> %OUT% -D%D% -Sdodgerblue2 -Cred 
rem	gmt pscoast -R -J -O -K >> %OUT% -D%D% -Sdodgerblue2 -C-
	gmt pscoast -R -J -O -K >> %OUT% -D%D% -S- -Cred

REM	Dibujar Paises (1 paises, 2 estados/provincias en America, 3 limite maritimo)
	gmt pscoast -R -J -O -K >> %OUT% -D%D% -N1/0.2,-

REM	Dibujar Linea de Costa -D: Resolucion datos 
	gmt pscoast -R -J -O -K >> %OUT% -D%D% -W1/

REM	Resaltar paises DCW (-E). Codigos ISO 3166-1 alph-2. (AR: Argentina soberana, FK: Malvinas, GS: Georgias del Sur). Pintar de color (+g), Dibujar borde (+p). 

rem	gmt pscoast -R -J -O -K >> %OUT% -EAR,FK,GS+grosybrown2+p
	
REM	Resaltar provincias DCW (-E). Codigos ISO 3166-2:AR (X: Cordoba, L: La Pampa, J: San Juan).
rem	gmt pscoast -R -J -O -K >> %OUT% -EAR.X,AR.L,AR.J+gorange+p
rem	gmt pscoast -R -J -O -K >> %OUT% -E=NA+gyellow+p
rem	gmt pscoast -R -J -O -K >> %OUT% -E=AF+gblue+p

REM	Dibujar marco del mapa 
	gmt psbasemap -R -J -O -K >> %OUT% -Bg

REM	Dibujar paralelos principales y meridiano de Greenwich a partir del archivo paralelos.txt -Am (lineas siguen meridianos)
	gmt psxy -R -J -O -K "paralelos.txt" >> %OUT% -Ap -W0.50,.-

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

	del temp_* gmt.* %OUT%
	pause

REM	Ejercicios Sugeridos
REM     ***********************************************************************
REM	1. Cambiar el horizonte del mapa a 60 y 90° (horizon, linea 14).
REM	2. Centrar mapa en Moscú (Long0: 37.617778. Lat0: 55.755833) y en otra ciudad (buscar en internet sus coordenadas; linea 14).
REM	3. Cambiar la resolucion de la base de datos de GSHHG a (c)ruda, (l)ow, (m)edium, (h)igh, (f)ull (linea 21).
REM	4. Resaltar otros países y 2 continentes (=AF, =AN, =AS, =EU, =OC, =NA o =SA) con distintos colores. Buscar código ISO y definir color (linea 62-63).
REM	5. Resaltar 2 provincias Argentinas (linea 65).
