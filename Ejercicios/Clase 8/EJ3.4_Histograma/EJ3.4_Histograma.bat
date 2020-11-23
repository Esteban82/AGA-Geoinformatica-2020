ECHO OFF
cls


REM	Variables del Mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ3.4_Histograma
	echo %title%

rem	Region Geografica/Figura (WESN)
	SET	REGION=0/4540/0/5000

REM	Proyeccion No Geografica. Linear, Logaritmica, Exponencial. JXwidth[/height]
	SET	PROJ=X-15c/10c

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------
REM	Parametros de Fuentes: Titulo del grafico, del eje (label) y unidades del eje (ANNOT_PRIMARY)
	gmtset	FONT_TITLE 16,4,Black
	gmtset	FONT_LABEL 10p,19,Red
	gmtset	FONT_ANNOT_PRIMARY 8p,Helvetica,Black
	gmtset	FONT_ANNOT_SECONDARY 7p,Helvetica,Black

	gmtset	MAP_FRAME_TYPE fancy

	gmtset	MAP_ANNOT_OFFSET_SECONDARY=5p
	gmtset	MAP_GRID_PEN_SECONDARY=1p

REM	Grafico Cartesiano
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear Grafico
	gmt psxy -J%PROJ% -R%REGION% -T -K -P > %OUT%

REM	Definir color de fondo del grafico (+g) 
	gmt psbasemap -R -J -O -K >> %OUT% -B+glightblue

REM	Titulo de la figura
	gmt psbasemap -R -J -O -K >> %OUT% -B+t"Histograma Dataciones U/Pb"

rem	Titulo de los ejes (X Y).
REM	-----------------------------------------------------------------------------------------------------------
REM	Eje y
	gmtset	MAP_FRAME_AXES WS
	gmt psbasemap -R -J -O -K >> %OUT% -Byafg+l"Frecuencia (\045)"

REM	Eje X. Primario (p) y secundario (s). 
	gmt psbasemap -R -J -O -K >> %OUT% -Bpx500f100
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bsxc"Eones.txt"+l"Eones (Ma)"
	gmt psbasemap -R -J -O -K >> %OUT% -Bsxc"Eras_Geologicas2.txt"+l"Eras (Ma)"

REM	Dibujar Histrograma. Definir borde (-L), relleno (-G), agregar valores (-D).
REM	Ancho de la clase (bin width) del Histograma (-W). Tipo de Histograma: Contar (-Z0), Frecuencia (-Z1). -Q: histograma acumulativo.
rem	gmt pshistogram -R -J -O -K >> %OUT% "U-PB_Ages.txt" -L1p -Gorange -W100 -Z1 
rem	gmt pshistogram -R -J -O -K >> %OUT% "U-PB_Ages.txt" -L1p -Gorange -W200 -Z1 
	gmt pshistogram -R -J -O -K >> %OUT% "U-PB_Ages.txt" -L1p -Gorange -W50  -Z0 
	gmt pshistogram -R -J -O -K >> %OUT% "U-PB_Ages.txt" -L1p          -W1	 -Z0 -Q
rem	gmt pshistogram -R -J -O -K >> %OUT% "U-PB_Ages.txt" -L1p -Gorange -W100 -Z0 
rem	gmt pshistogram -R -J -O -K >> %OUT% "U-PB_Ages.txt" -L1p -Gorange -W100 -Z1 -D
rem	gmt pshistogram -R -J -O -K >> %OUT% "U-PB_Ages.txt" -L1p -Gorange -W100 -Z1 -D+b

REM	Recuadro. -B0
	gmt psbasemap -R -J -O -K >> %OUT% -B0wesn

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Ver como agregar un eje primario y secundario (lineas 55 y 56).
REM	2. El negativo de la variable PROJ revierte la orientación del eje X. Ver los gráficos que resultan de agregar y quitar el "-" en los ejes.
REM	3. Probar el resultados de las disintantes combinacioes para hacer los histogramas (lineas 57 a 63). Ajustar REGION para que se visualicen todos los datos.
