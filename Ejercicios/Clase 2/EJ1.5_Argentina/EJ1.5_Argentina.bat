ECHO off
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ1.5_Argentina
	echo %title%

REM	Region geografica del mapa: Bordes (W/E/S/N) o esquinas (W/S/E/Nr)
REM	Region: Buenos Aires (W/S/E/Nr) 
rem	SET	REGION=-64/-42/-56/-33r

REM	Region: San Juan
rem	SET	REGION=-71/-66.5/-33/-28

REM	Region: Argentina
	SET	REGION=-78/-50/-56/-21
rem	SET	REGION=-81/-55/-53/-21r

REM	Proyecciones Cilindricas: 
REM	(C)assini, C(y)lindrical equal area: Lon0/lat0/Width
REM	Miller cylindrical (J): Lon0/Width
REM	(M)ercartor, E(q)udistant cilindrical, (T)ransverse Mercator: (Lon0(/Lat0/))Width
REM	(U)TM: Zone/Width
rem	SET	PROJ=C-65/-35/13c
rem	SET	PROJ=J-65/13c
rem	SET	PROJ=T-60/-30/13c
	SET	PROJ=M15c
rem	SET	PROJ=U-20/13c

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

	gmt grdimage -R -J -O -K >> %OUT% "@earth_day_01m" -Vi

REM	Resaltar paises DCW (AR: Argentina soberana, FK: Malvinas, GS: Georgias del Sur y Sandwich del Sur)
	gmt pscoast -R -J -O -K  >> %OUT% -EAR,FK,GS+grosybrown2+p

REM	Pintar areas húmedas: Oceanos (-S) y Lagos (-C+l) y Rios-Lagos (-C+r)
rem	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Sdodgerblue2 -Cgreen+l -Cred+r
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Sdodgerblue2 -C-

REM	Datos Instituto Geografico Nacional (IGN)
REM	-----------------------------------------------------------------------------------------------------------

REM	Cursos y Cuerpos de Agua
	gmt psxy -R -J -O -K >> %OUT% "Datos\areas_de_aguas_continentales_perenne.shp"  -Gdodgerblue2
	gmt psxy -R -J -O -K >> %OUT% "Datos\lineas_de_aguas_continentales_perenne.gmt" -Wfaint,darkblue

REM	Limites Interprovincial
	gmt psxy -R -J -O -K >> %OUT% "Datos\linea_de_limite_070111.shp" -Wthinner,black,-.

REM 	Red vial y ferroviaria
	gmt psxy -R -J -O -K >> %OUT% "Datos\RedVial_Autopista.gmt"        -Wthinnest,black
	gmt psxy -R -J -O -K >> %OUT% "Datos\RedVial_Ruta_Nacional.gmt"    -Wthinnest,black
	gmt psxy -R -J -O -K >> %OUT% "Datos\RedVial_Ruta_Provincial.gmt"  -Wfaint,black
	gmt psxy -R -J -O -K >> %OUT% "Datos\lineas_de_transporte_ferroviario_AN010.shp"      -Wthinnest,darkred
	
REM	Localidades y Areas Urbanas. -SsimboloTamaño. Simbolos: A (star), C (Círculo), D (Diamante), G (octagono), H (hexagono), I (triangulo invertido), N (pentagono), S (cuadrado), T (triangulo). 
REM	Tamaño: diámetro del círculo (Mayuscula: misma área que el circulo; Minúscula (diámetro del círculo que abarca a las símbolos)
	gmt psxy -R -J -O -K >> %OUT% "Datos\puntos_de_asentamientos_y_edificios_localidad.shp" -Sc0.04 -Ggray19
	gmt psxy -R -J -O -K >> %OUT% "Datos\areas_de_asentamientos_y_edificios_020105.shp"     -Wfaint -Ggreen

REM	Pueblos. Ejercicio. Combinación de -S -W -G
rem	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT% -Sc0.3 -Wred -Ggreen
rem	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT% -Sc0.3 -Wred 
rem	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT% -Sa0.3       -Ggreen
rem	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT%         -Wred -Ggreen
rem	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT%         -Wred         
rem	gmt psxy -R -J -O -K "Participantes.txt" >> %OUT%               -Ggreen

REM	Datos de GSHHG
REM	-----------------------------------------------------------------------------------------------------------

REM	Dibujar Marco. -B0 solo borde. -Baf con anotaciones y marcas automaticas.
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias, Estados, etc. N3: limites marítimos (Nborder[/pen])
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -N1/0.75,-

REM	Dibujar Linea de Costa (level/, where level is 1-4 and represent coastline, lakeshore, island-in-lake shore, and lake-in-island-in-lake shore). -Amin_area(/min_level/max/level): Filtro para dibujar lineas de costa.
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Wfaint -A0/0/4

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

REM	Eliminar archivos temporales
	del temp_* gmt.* %OUT%
	pause

REM	-----------------------------------------------------------------------------------------------------------
REM	Ejercicios Sugeridos:
REM	1. Descargar datos del IGN (en formato SHP o utilizar cualquier otro SHP) que represente un polígono, una línea y puntos. 
REM	2. Guardar en una carpeta y reemplazar en el script la ruta absoluta de los archivos.
REM	3. Ejercicio de combinación de argumentos -S -G -W para dibujar símbolos, líneas y áreas (lineas 77 a 83).
REM	4. Dibujar los pueblos con distintos símbolos (estrella, cuadrado, círculo).
