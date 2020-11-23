ECHO OFF
cls

REM	Variables del Mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Title of the map
	SET	title=3.7_Grafico_Dunlop2002
	echo %title%

REM	Region Geografica/Figura (WESN)
	SET	REGION=1/100/0.005/1

REM	Proyeccion Logaritmica (l). Ancho y alto en cm
	SET	PROJ=X15cl/10cl

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------
REM	Parametros de Fuentes: Titulo del grafico, del eje (label) y unidades del eje (ANNOT_PRIMARY)
	gmtset	FONT_TITLE 16,4,Black
	gmtset	FONT_LABEL 10p,19,Red
	gmtset	FONT_ANNOT_PRIMARY 8p,Helvetica,Blue

	gmtset PS_CHAR_ENCODING ISOLatin1+
	gmtset IO_SEGMENT_MARKER B

REM	Ejes a dibujar. Mayuscula: eje y unidades. Minuscula: eje. Sin letra, no dibuja el eje.
	gmtset	MAP_FRAME_AXES WS

REM	Dibujar Mapa 
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear Grafico
	gmt psxy -J%PROJ% -R%REGION% -T -K -P > %OUT%

REM	Tìtulo de la figura (-B+t)
	gmt psbasemap -R -J -O -K >> %OUT% -B+t"Diagrama de Dunlop 2002"

REM	Color de fondo del grafico (-B+g"color").
	gmt psbasemap -R -J -O -K >> %OUT% -B+g200

REM	Titulo de los ejes (X Y) por separado: (a)notacion), (f)rame y (l)abel. @- Inicio/Fin Subindice. 
	gmt psbasemap -R -J -O -K >> %OUT% -Bxa2f3+l"H@-RC@-/H@-C@-"
	gmt psbasemap -R -J -O -K >> %OUT% -Bya2f3+l"J@-RS@-/J@-S@-"

REM	Lineas para grafico Dunlop 2002
REM	**************************************************************
REM	Crear archivo auxiliar para las lineas
	echo 1,0.02	>> "temp_Lineas"
	echo 100,0.02	>> "temp_Lineas"
	echo 		>> "temp_Lineas"
	echo 1,0.5	>> "temp_Lineas"
	echo 100,0.5	>> "temp_Lineas"
	echo 		>> "temp_Lineas"
	echo 2,0.005	>> "temp_Lineas"
	echo 2,1	>> "temp_Lineas"
	echo 		>> "temp_Lineas"
	echo 5,0.005	>> "temp_Lineas"
	echo 5,1	>> "temp_Lineas"

REM	Graficar Lineas del Grafico
	gmt psxy -R -J -O -K "temp_Lineas" -Wthin >> %OUT%
REM	***********************************


REM	Nombre Campos
REM	**************************************************************
	echo 1.50,0.75,SD      >  "temp_Campos"
	echo 3.75,0.20,PSD     >> "temp_Campos"
	echo 10.00,0.10,SP+SD  >> "temp_Campos"
	echo 15.00,0.01,MD     >> "temp_Campos"

REM	Poner Nombre de los Campos
	gmt pstext -R -J -O -K >> %OUT% "temp_Campos" -F+f12,17,green -W -Gwhite@50 
REM	***********************************


REM	Graficar Datos
	gmt psxy -R -J -O -K "Datos.txt"  >> %OUT% -: -Wthinnest -S0.2 -Ccategorical

REM	Leyenda
REM	-----------------------------------------------------------------------------------------------------------
REM	Archivo Auxiliar
	echo N 1 					   	>  temp_legend
	echo S 0.25c c 0.25c green thinnest 0.5c Rabot	   	>> temp_legend
	echo S 0.25c s 0.25c blue  thinnest 0.5c Hamilton  	>> temp_legend	
	echo S 0.25c t 0.25c red   thinnest 0.5c Sanctuary 	>> temp_legend
	echo S 0.25c d 0.25c cyan  thinnest 0.5c Haslum Craig 	>> temp_legend	
	
REM	Dibujar Leyenda
 	gmt pslegend -R -J -O -K "temp_legend" >> %OUT% -DjTR+w3/0+o0.3+jTR -F+gwhite+p+i+r+s 
rem 	gmt pslegend -R -J -O -K "temp_legend" >> %OUT% -DjTR+w3/0+o-1.7/0.2+jTR -F+gwhite+p+i+r+s 
rem 	gmt pslegend -R -J -O -K "temp_legend" >> %OUT% -DjBL+w3/0+o-1.7/0.2+jTC -F+gwhite+p+i+r+s 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

REM	Borrar temporales
	del temp_* %OUT% gmt.*
rem	pause

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1
