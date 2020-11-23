ECHO OFF
cls

REM	Variables del Mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ3.2_ClasificacionRocas_NbY-ZrTi_WF77
	echo %title%

rem	Region Geografica/Figura (WESN)
	SET	REGION=0.01/10/0.001/10

REM	Proyeccion No Geografica. Lineal, Logaritmica, Exponencial. JXwidth[/height]
	SET	PROJ=X15cl/10cl

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------
REM	Parametros de Fuentes: Titulo del grafico, del eje (label) y unidades del eje (ANNOT_PRIMARY)
	gmtset	FONT_TITLE 24,4,Black
	gmtset	FONT_LABEL 16p,19,Red
	gmtset	FONT_ANNOT_PRIMARY 12p,Helvetica,Black

REM	Ejes a dibujar. Mayuscula: eje y unidades. Minuscula: eje. Sin letra, no dibujta el eje.
	gmtset	MAP_FRAME_AXES WeSn

REM	Dibujar Mapa 
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear Grafico
	gmt psxy -J%PROJ% -R%REGION% -T -K -P > %OUT%

REM	Definir color de fondo del grafico (+g) 
	gmt psbasemap -R -J -O -K >> %OUT% -B+g200

REM	Tìtulo de la figura
	gmt psbasemap -R -J -O -K >> %OUT% -B+t"Diagrama de Clasificaci\363n de Rocas"

REM	Titulo de los ejes (X Y) por separado: (a)notacion), (f)rame y (l)abel. p: anotacion cientifica. l: orden de mangnitud del valor (100 se anota como 2)
	gmt psbasemap -R -J -O -K >> %OUT% -Bxa2f3+l"Nb/Y (ppm)"
	gmt psbasemap -R -J -O -K >> %OUT% -Bya1f3+l"Zr/Ti (ppm)"
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bya2f3+l"Zr/Ti (ppm)"
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bya3f3+l"Zr/Ti (ppm)"
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bya1f3p+l"Zr/Ti (ppm)"
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bya1f3l+l"Zr/Ti (ppm)"

REM	Graficar Campos
	gmt psxy -R -J -O -K >> %OUT% "NbY_ZrTi.txt" -Wthin

REM	Graficar Datos
	gmt psxy -R -J -O -K >> %OUT% "Litofacies2" -Sc0.25 -Gred
	gmt psxy -R -J -O -K >> %OUT% "Litofacies3" -St0.25 -Gblue
	gmt psxy -R -J -O -K >> %OUT% "Lacolito"    -Ss0.25 -Ggreen

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del gmt.* %OUT%

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Ver el efecto de la "l" que aparece en PROJ (línea 15). Borrarlos. 
REM	2. Modificar rango de datos (linea 12) con escala logaritmica.
REM	3. Probar las otras combinaciones para dibujar los intervalos en el eje logarítmico Y: a1, a2 y a3 y agregando p y l (líneas 43 a 47). Los intervalos se pueden aplicar a, f y g. 
