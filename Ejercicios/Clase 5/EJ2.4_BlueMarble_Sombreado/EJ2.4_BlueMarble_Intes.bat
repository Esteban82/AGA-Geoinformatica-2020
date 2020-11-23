ECHO OFF
cls


REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Resolucion de Blue/Black Marble: 01d, 30m, 20m, 15m, 10m, 06m, 05m, 04m, 03m, 02m, 01m, 30s
	SET	RES=03m

REM	Intensidad sombreado (valores > 0 hasta 1). Normalización con distribución cumulativa Laplace (e) o Cauchy (t).
	SET	N=t1.00
rem	SET	N=e0.50

REM	Titulo del mapa
	SET	title=EJ2.4_BlueMarble_%RES%_Intes_N%N%
	echo %title%

REM	Proyecciones acimutales requieren 3 parametros + 1 opcional (lon0/lat0[/horizon]/width
REM	L(a)mbert Equal Area; (S)tereographic; Orto(g)rafica; (E)quidistante
	SET	PROJ=G-65/-30/90/15c

REM	Region geografica del mapa (W/E/S/N) d=-180/180/-90/90 g=0/360/-90/90
	SET	REGION=d
	
REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermdiate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM 	Nombre archivo de salida y otras 
	SET	OUT=%title%.ps
	SET	SHADOW=temp_%title%_shadow.nc

REM	Parametros por Defecto
REM	-----------------------------------------------------------------------------------------------------------

REM	Sub-seccion GMT
	gmtset GMT_VERBOSE w

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	@: Dato que se descarga del DATA_SERVER. Solo en GMT6.
REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A). 
	gmt grdgradient "@earth_relief_%RES%" -N%N% -A45 -G"%SHADOW%"

REM	Graficar Imagen Satelital BlueMarble (day) o BlackMarble (night).
rem	gmt grdimage -R -J -O -K >> %OUT% "@earth_night_%RES%" 
rem	gmt grdimage -R -J -O -K >> %OUT% "@earth_night_%RES%" -I"temp_intens.nc"
	gmt grdimage -R -J -O -K >> %OUT% "@earth_day_%RES%"   -I"%SHADOW%"

REM	Dibujar Linea de Costa
rem	gmt pscoast -R -J -O -K -D%D% >> %OUT% -W0.5/white
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -N1/0.35,white
rem	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT% -Sa0.3       -Ggreen

REM	Dibujar marco del mapa 
	gmt psbasemap -R -J -O -K >> %OUT% -B0

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -E400 -A

REM	Borrar archivos temporales
	del temp_* gmt.* %OUT%
rem	pause

REM	Ejercios Sugeridos
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Probar con otros valores de intensidad de sombrado para ambos métodos (lineas 10-11).
REM	2. Cambiar a la imagen satelital de noche (black marble) y repetir ejercicio 1.
