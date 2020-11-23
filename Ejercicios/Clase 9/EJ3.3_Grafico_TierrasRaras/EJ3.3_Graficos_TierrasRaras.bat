ECHO OFF
cls

REM	Variables del Mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ3.3_Graficos_TierrasRaras
	echo %title%

rem	Region Geografica/Figura (WESN)
	SET	REGION=0.5/15.5/1/1000

REM	Proyeccion No Geografica. Linear, Logaritmica, Exponencial. JXwidth[/height]
	SET	PROJ=X10c/5cl

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------
REM	Parametros de Fuentes: Titulo del grafico, del eje (label) y unidades del eje (ANNOT_PRIMARY)
	gmtset	FONT_TITLE 10,4,Black
	gmtset	FONT_LABEL 7p,19,Red
	gmtset	FONT_ANNOT_PRIMARY 6p,Helvetica,Black

REM	Sub-seccion GMT
	gmtset GMT_VERBOSE w

REM	Sub-seccion MAPA
	gmtset MAP_FRAME_PEN thin
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0

REM	Sub-seccion PROJECCION
	gmtset PROJ_LENGTH_UNIT cm
	
REM	Sub-seccion PS
	gmtset PS_MEDIA A4

REM	Grafico Cartesiano
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear Grafico
	gmt psxy -J%PROJ% -R%REGION% -T -K -P > %OUT%

REM	Definir color de fondo del grafico (+g) 
	gmt psbasemap -R -J -O -K >> %OUT% -B+g200
 
REM	Tìtulo de la figura
	gmt psbasemap -R -J -O -K >> %OUT% -B+t"Gr\341fico Tierras Raras"

REM	Titulo de los ejes (X Y) por separado: (a)notacion), (f)rame y (l)abel. p: notacion cientifica. a1f3p. 
	gmt psbasemap -R -J -O -K >> %OUT% -B0wesn 
	gmtset	MAP_FRAME_AXES WS
	gmt psbasemap -R -J -O -K >> %OUT% -Bxc"REE"+l"Tierras Raras"
	gmt psbasemap -R -J -O -K >> %OUT% -Bya1f3+l"Roca/Condrita"

REM	Calcular. Normalizar valores de las tierras raras con respecto a los valores de la condrita.
	gmt math "AB1.txt" "Condrita.txt" DIV = "temp_Muestra"

REM	Graficar Datos
	gmt psxy -R -J -O -K "temp_Muestra" >> %OUT% -Wthin,red
	gmt psxy -R -J -O -K "temp_Muestra" >> %OUT% -Sc0.15 -Gblue

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

REM	Borrar temporales
	del temp_* %OUT% gmt.*

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Ver las diferencias de los ejes dibujados con repecto a los graficos anteriores. 
REM	En la línea 58 se realiza una operación matemática entre los datos.
REM	Ver entrada 3.3 en el blog de como personalizar (custom) el eje x con los datos del archivo REE -BxcREE (línea 54).
REM	Notar que en la líneas 61 y 62 se grafican los datos del archivo "temp_Muestra" sin extensión.
REM	Modificar el MAP_FRAME_TYPE de fancy a graph (linea 27) y reemplazar -B0wesn por -B0ws (linea 52).
