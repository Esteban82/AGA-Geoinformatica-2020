ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ2.2_ImagenSatelital_Malvinas
	echo %title%
 
REM	Region Geografica. Islas Malvinas
	SET	REGION=-61.5/-57.5/-52.5/-51

REM	Proyeccion Cilindrica: (M)ercator y Ancho de la figura
	SET	PROJ=M15c

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros por Defecto
REM	-----------------------------------------------------------------------------------------------------------
REM	Parametros de Fuentes: Titulo del grafico, del eje (label) y unidades del eje (ANNOT_PRIMARY)
	gmtset	FONT_TITLE 10,4,Blue
	gmtset	FONT_LABEL 8p,19,Green
	gmtset	FONT_ANNOT_PRIMARY 6p,Helvetica,Yellow

REM	Sub-seccion FORMATO de Coordenadas en el Margen.
rem	gmtset FORMAT_GEO_MAP ddd.xxxF
	gmtset FORMAT_GEO_MAP ddd.xxx
rem	gmtset FORMAT_GEO_MAP ddd:mm:ss
rem	gmtset FORMAT_GEO_MAP ddd:mm:ssF
rem	gmtset FORMAT_GEO_MAP ddd:mm:ssG

REM	Sub-seccion MAPA. 
rem	gmtset MAP_FRAME_TYPE inside
rem	gmtset MAP_FRAME_TYPE fancy+
	gmtset MAP_FRAME_TYPE fancy

REM	Ejes a dibujar. Mayuscula: eje y unidades. Minuscula: eje. Sin letra: no dibuja el eje (para gráficos XY).
	gmtset	MAP_FRAME_AXES wESn
rem	gmtset	MAP_FRAME_AXES WeS

REM	Nivel de mensajes. (e)rrores, (w)arnings, (i)nformation
	gmtset GMT_VERBOSE w

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear encabezado del archivo de salida (ps) y setea las variables
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Crear imagen a partir de grillas RGB
rem	gmt grdimage -R -J -O -K >> %OUT% "Malvinas_r.grd" "Malvinas_g.grd" "Malvinas_b.grd"

REM	Pintar areas húmedas: Oceanos (-S) y Lagos (-C+l) o Rios-Lagos (-C+r)
rem	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Sdodgerblue2 -A0/0/1

REM	Dibujar Linea de Costa
rem	gmt pscoast -R -J -O -K -D%D% >> %OUT% -W1/faint

REM	Dibujar Norte (-Td). Ubicación definida por coordenads geográficas (g) centrado en Lon0/Lat0, ancho (+w). Opcionalmente se pueden definir a cantidad de ejes (+f) de , puntos cardinales (+l)
rem	gmt psbasemap -R -J -O -K >> %OUT% -Tdg-58/-51.25+w1.25c+f3+lO,E,S,N
rem	gmt psbasemap -R -J -O -K >> %OUT% -Tdg-58/-51.25+w1.25c+f2	    
rem	gmt psbasemap -R -J -O -K >> %OUT% -Tdg-58/-51.25+w1.25c
	gmt psbasemap -R -J -O -K >> %OUT% -Tdg-58/-51.25+w1.25c+f1+l       

REM	Agregar Norte personalizado a partir de una imagen
rem	gmt psimage -R -J -O -K "Norte.png" >> %OUT% -Dg-58/-51.25+w0.9c

REM	Dibujar Escala en el mapa centrado en -Lg Lon0/Lat0, calculado en meridiano (+c), ancho (+w), elegante(+f), unidad arriba de escala (+l), unidad con los valores (+u)
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f+l
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f+u
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f
	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w40+f+l
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f   -Fl+gwhite
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f   -Fl+gwhite+p+r
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f   -Fl+gwhite+p+i
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f   -Fl+gwhite+p+i+r
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-58/-52:20+c-51:45+w50k+f+u -Fl+gwhite+p+i+r+s

REM	Dibujar frame (-B): Anotaciones (a), frame (f), grilla (g). Ejes por separado (x, y)
rem	gmt psbasemap -R -J -O -K >> %OUT% -Baf
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bafg
	gmt psbasemap -R -J -O -K >> %OUT% -Byaf          -Bxaf
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bxafg         -Byaf
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bxa1f0.5g0.25 -Byaf

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t).
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp_* gmt.* 
	del %OUT%
rem	pause

REM	-----------------------------------------------------------------------------------------------------------
REM	Ejercicios Sugeridos:
REM	1. Norte Geográfico (línea 62).
REM	1.2. Ver los nortes geográficos que resultan de las distintans combinaciones de: +f(1,2,3), +l y +lO,E,S,N. (líneas 63 a 66).
REM	1.3. Ver agregar norte personalizado a partir de un una imagen (lineas 68,69).
REM
REM	2. Escala gráfica (línea 71).
REM	2.1. Cambiar el tamaño de la escala de 50 a 100 km (+w50k, linea 72).
REM	2.2. Ver las escalas que resultan de la combinación de +f, +l y +u (líneas 72-75).
REM	2.3. Ver como cambian los recuadros de la escala con -Fl (lineas 76-80).

REM	3. Marco del Mapa (línea 82)
REM	3.1. Ver los marcos que resultan de las distintas combinaciones de: afg (lineas 83 a 87).
REM	3.2. Ver como cambian las coordenadas geográficas (del marco) según FORMAT_GEO_MAP (lineas 31 a 34)
REM	3.3. Ver como cambian los ejes con las otros MAP_FRAME_TYPE (lineas 36-39)
REM	3.4. Ver como cambian los ejes al editar MAP_FRAME_AXES (lineas 42 a 43).

REM	4. Fuentes (lineas 25-28). Ver que tipo de fuente se utiliza para cada letra (norte, escala, coordenadas).
