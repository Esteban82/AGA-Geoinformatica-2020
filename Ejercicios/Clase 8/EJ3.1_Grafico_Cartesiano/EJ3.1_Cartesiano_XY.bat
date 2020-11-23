ECHO OFF
cls

REM	Variables del Mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Title of the map
	SET	title=EJ3.1_Cartesiano_XY
	echo %title%

REM	Region Geografica/Figura (WESN) Xmin/Xmax/Ymin/Ymax
	SET	REGION=50/80/0/6

REM	Proyeccion No Geografica. Lineal, Logaritmica, Exponencial. JXwidth[/height]
rem	SET	PROJ=X15c
	SET	PROJ=X15c/5c

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------
REM	Parametros de Fuentes: Titulo del grafico, del eje (label) y unidades del eje (ANNOT_PRIMARY)
	gmtset	FONT_TITLE 32,4,Black
	gmtset	FONT_LABEL 16p,19,Red
	gmtset	FONT_ANNOT_PRIMARY 12p,Helvetica,green

	gmtset PS_CHAR_ENCODING ISOLatin1+

REM	Ejes a dibujar. Mayuscula: eje y unidades. Minuscula: eje. Sin letra, no dibuja el eje.
	gmtset	MAP_FRAME_AXES WESN

REM	Dibujar Mapa 
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear Grafico
	gmt psxy -J%PROJ% -R%REGION% -T -K -P > %OUT%


REM	Definir color de fondo del grafico (-B+g). gpdpi/patron:BcolorfondoFcolorfrente. Porcentaje de transparencia (-t)
rem	gmt psbasemap -R -J -O -K >> %OUT% -B+g200
	gmt psbasemap -R -J -O -K >> %OUT% -B+g200 -t80
rem	gmt psbasemap -R -J -O -K >> %OUT% -B+gp300/2 
rem	gmt psbasemap -R -J -O -K >> %OUT% -B+gp300/2:BredFgreen
rem	gmt psbasemap -R -J -O -K >> %OUT% -B+gp30/2:BredFgreen
rem	gmt psbasemap -R -J -O -K >> %OUT% -B+gp300/20:BredFgreen

REM	Titulo de los ejes (X Y) por separado: (a)notacion), (f)rame y (l)abel. Agregar prefijo (+p) y unidad (+u) a los valores. @- Inicio/Fin Subindice. 
	gmt psbasemap -R -J -O -K >> %OUT% -Bxa5f1+l"SiO@+2@+ (wt. \045)"
	gmt psbasemap -R -J -O -K >> %OUT% -Bya1f1+l"MgO (wt. \045)"

REM	Graficar Datos
	gmt psxy -R -J -O -K  >> %OUT% "SiO2-MgO.txt" -Sc0.25 -Gdeepskyblue3
	gmt psxy -R -J -O -K  >> %OUT% "SiO2-MgO.txt" -St0.25 -Gred

REM	Tìtulo de la figura (-B+t)
	gmt psbasemap -R -J -O -K >> %OUT% -B+t"Diagrama Harker" -Y2c

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -T -O >> %OUT%

REM	Convertir ps en otros formatos: %EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

REM	Borrar Temporales
	del %OUT% gmt.*
rem	pause

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Editar  FONT_TITLE, FONT_LABEL y FONT_ANNOT_PRIMARY (lineas 24 y 26).
REM	2. Modificar el rango de datos (REGION; linea 12) y editar los intervalos de los ejes X Y (lineas 43 y 44)
REM	3. Modificar las dimensiones del gráfico a 7 cm de ancho y 5 cm de alto (lineas 16).
REM	4. Modificar los títulos de los ejes y el título del gráfico. Utilizar acentos y símbolos ISOLatin1+, escribir en superíndice y subrayado (lineas 39, 50 y 51). 

