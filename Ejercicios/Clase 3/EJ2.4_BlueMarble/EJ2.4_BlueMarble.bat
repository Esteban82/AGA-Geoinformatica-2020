ECHO OFF
cls


REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Resolucion de Blue/Black Marble: 01d, 30m, 20m, 15m, 10m, 06m, 05m, 04m, 03m, 02m, 01m, 30s
	SET	RES=01d

REM	Titulo del mapa
	SET	title=EJ2.4_BlueMarble_%RES%
	echo %title%

REM	Proyecciones acimutales requieren 3 parametros + 1 opcional (lon0/lat0[/horizon]/width
REM	L(a)mbert Equal Area; (S)tereographic; Orto(g)rafica; (E)quidistante
	SET	PROJ=G-65/-30/90/15c

REM	Region geografica del mapa (W/E/S/N) d=-180/180/-90/90 g=0/360/-90/90
	SET	REGION=d
	
REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermdiate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros por Defecto
REM	-----------------------------------------------------------------------------------------------------------

REM	Sub-seccion GMT
	gmtset GMT_VERBOSE w

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Graficar Imagen Satelital BlueMarble (day) o BlackMarble (night).
REM	@: Dato que se descarga del DATA_SERVER. Solo en GMT6.
	gmt grdimage -R -J -O -K >> %OUT% "@earth_day_%RES%"
rem	gmt grdimage -R -J -O -K >> %OUT% "@earth_night_%RES%"

REM	Dibujar Linea de Costa
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -W1/
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -N1/0.75,white,-

	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT% -Sa0.3       -Ggreen


REM	Dibujar marco del mapa 
	gmt psbasemap -R -J -O -K >> %OUT% -B0

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -E400

REM	Borrar archivos temporales
	del temp_* gmt.* %OUT%
	pause

REM	Ejercios Sugeridos
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Probar las otras resoluciones disponibles hasta obtener una imagen de buena calidad (linea 8)
REM	2. Cambiar a la imagen satelital de noche (black marble, comentar linea 40 y descomentar la 42).
REM	3. Agregar en la linea 43 los comandos para dibujar los límites de los países (-N1) y de las provincias (-N2) (sacarlos del script 1.4). Agregar en la 
