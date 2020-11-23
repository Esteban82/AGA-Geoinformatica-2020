ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ10_MapaTectonico_Leyenda_Inset
	echo %title%
 
REM	Region Geografica
	SET	REGION=-79/-20/-63/-50

REM	Proyeccion Cilindrica: (M)ercator
	SET	PROJ=M15c

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	color=temp_%title%.cpt

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------
REM	Parametros de Fuentes: Titulo del grafico, del eje (label) y unidades del eje (ANNOT_PRIMARY)
	gmtset	FONT_TITLE 16,4,Black
	gmtset	FONT_LABEL 10p,19,Black
	gmtset	FONT_ANNOT_PRIMARY 8p,Times-Roman,Black

REM	Sub-seccion MAPA
	gmtset FORMAT_GEO_MAP ddd:mm:ssG
	gmtset MAP_FRAME_AXES WesN
	gmtset MAP_FRAME_TYPE fancy+
	gmtset MAP_FRAME_WIDTH 0.1
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0.3	
	gmtset MAP_SCALE_HEIGHT 0.1618
	gmtset MAP_TICK_LENGTH_PRIMARY 0.1

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P -Y5c > %OUT%

REM	Pintar areas húmedas
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Sdodgerblue2  

REM	Dibujar Linea de Costa de Oceano-Continente (nivel 1)
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -W1/faint

REM	Datos Tectonicos
REM	-----------------------------------------------------------------------------------------------------------
REM	Plates Project: Limite de Placas
	gmt psxy -R -J -O -K "Datos\transform.gmt" >> %OUT% -W0.4,black -Sf1.5/0.25+l+s -Gblack
	gmt psxy -R -J -O -K "Datos\trench.gmt"    >> %OUT% -W0.4,green -Sf0.75/0.2+l+t -Ggreen
	gmt psxy -R -J -O -K "Datos\ridge.gmt"     >> %OUT% -W1.0,red
	gmt psxy -R -J -O -K "Datos\ridge.gmt"     >> %OUT% -W0.4,white

REM	Plates Project: LIPs
	gmt psxy -R -J -O -K "Datos\LIPS.2011.gmt" >> %OUT% -Gp300/29

REM	Lineamientos de Fabrica del Lecho Marino
REM	Zonas de Fraturas (FZ)
	Set Linea=0.5,violet
	gmt psxy -R -J -O -K "Datos\GMT\GSFML_SF_FZ_JW.gmt"   -W%Linea% >> %OUT%
	gmt psxy -R -J -O -K "Datos\GMT\GSFML_SF_FZ_KM.gmt"   -W%Linea% >> %OUT%
	gmt psxy -R -J -O -K "Datos\GMT\GSFML_SF_FZ_MC.gmt"   -W%Linea% >> %OUT%
	gmt psxy -R -J -O -K "Datos\GMT\GSFML_SF_FZ_RM.gmt"   -W%Linea% >> %OUT%
	gmt psxy -R -J -O -K "Datos\GMT\GSFML_SF_FZLC_KM.gmt" -W%Linea% >> %OUT%

REM	Dorsales extintas (ER)
	gmt psxy -R -J -O -K "Datos\GMT\GSFML_SF_ER_KM.gmt"   -W0.4,orange >> %OUT%

REM	Dibujar Sismos
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear cpt para sismos superficiales (0-30 km), someros (30-100 km), intermedios (100 - 300 km) y profundos (300-1000 km)
	gmt makecpt -Cred,orange,green,blue  -T0,30,100,300,1000  > "temp_seis.cpt"

REM	Dibujar Sismos del USGS segun magnitud (-Scpasc), y color segun profundidad (-Ccpt).
	gmt psxy -R -J -O -K "Sismos_Input\query*.csv" -h1 >> %OUT% -W0.1 -i2,1,3,4 -Scp  -C"temp_seis"   

REM	Dibujar Mecanismos Focales
REM	-----------------------------------------------------------------------------------------------------------
REM	Datos Global CMT. Tamaño proporcional a la magnitud (-M: Tamaño Fijo)
	gmt psmeca -R -J -O -K "Mecanismos_Focales\CMT_*.txt" >> %OUT% -Sd0.15/0 -Gblack
rem	gmt psmeca -R -J -O -K "Mecanismos_Focales\CMT_*.txt" >> %OUT% -Sd0.15/0 -Gorange
	
REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar Escala en el mapa centrado en -Lg Lon0/Lat0, calculado en meridiano (+c), ancho (+w).
	gmt psbasemap -R -J -O -K >> %OUT% -Lg-74/-62+c-54+w500k+f+l 

REM	Dibujar marco (-B): Anotaciones (a), frame (f)
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf

REM	Dibujar leyenda
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear archivo para hacer la leyenda
REM	Leyenda. H: Encabezado. D: Linea horizontal. N: # columnas verticales. V: Linea Vertical. S: Símbolo. M: Escala
	echo H 10 Times-Roman Leyenda del Mapa >> temp_legend
    	echo N 3 >> temp_legend
	echo S 0.25c -     0.5c -     3.0p,red       0.75c Dorsal                  >> temp_legend
	echo S 0.25c f+l+t 0.5c green 1.0p,green     0.75c Subucci\363n            >> temp_legend
	echo S 0.25c f+l+s 0.5c -     1p,black       0.75c L\355mite Transforme    >> temp_legend
	echo G 0.075c >> temp_legend

	echo S 0.25c c 0.25c red   0.40p     0.5c Sismos someros (0-100 km)        >> temp_legend
	echo S 0.25c c 0.25c green 0.40p     0.5c Sismos intermedios (100-300 km)  >> temp_legend
	echo S 0.25c c 0.25c blue  0.40p     0.5c Sismos profundos (300-700 km)    >> temp_legend
	echo G 0.075c >> temp_legend

	echo N 4 >> temp_legend
	echo S 0.25c r 0.5c p300/29  0.25p    0.75c LIPS          	   	   >> temp_legend
	echo S 0.25c r 0.5c purple4  0.25p    0.75c Ofiolitas      		   >> temp_legend
	echo S 0.25c - 0.5c - 1.0p,violet     0.75c Zonas de Fracturas 		   >> temp_legend
rem	echo S 0.25c - 0.5c - 0.80p,orange    0.75c Dorsales Extintas 		   >> temp_legend
	echo S 0.25c - 0.5c - 0.60p,orange,dotted  0.75c Dorsales Extintas 		   >> temp_legend

	echo G 0.075c >> temp_legend
	echo M -70 -57 500+u f                          >> temp_legend

REM	Graficar leyenda
	gmt pslegend -R -J -O -K "temp_legend" >> %OUT% -Dx7.5/-0.2+w15/0+jTC -F+p+i+r

REM	-----------------------------------------------------------------------------------------------------------
REM    	Leyenda Auxiliar
	echo H 10 Times-Roman  > "temp_legend"
	echo N 3 >> "temp_legend"
	echo S 0.25c - 0.5c - 1.0p,white 0.75c >> "temp_legend"
    	gmt pslegend -R -J -O -K "temp_legend" >> %OUT% -Dx7.5/-0.2+w15/0+jTC
    
REM	-------------------------------------------------

REM	Mapa de Ubicación (INSET)
REM	-----------------------------------------------------------------------------------------------------------
REM	Recuadro debajo Mapa Inset y ubicación en X e Y
rem	gmt psbasemap -R -J -O -K  >> %OUT% -DjTR+w2.5c -V
rem	gmt psbasemap -R -J -O -K  >> %OUT% -DjTR+w2.5c -V -F+gwhite+p1p+c0.1c+s
rem	pause
 	
REM	Dibujar Mapa INSET
	gmt pscoast -Rd -JG-49.5/-56.5/2.5c -O -K >> %OUT% -W0.3p,black -B90 -Da -Ggray -Swhite -X12.8c -Y4.0c     --MAP_FRAME_PEN=thin
rem	gmt pscoast -Rd -JG-49.5/-56.5/2.5c -O -K >> %OUT% -W0.3p,black -B90 -Da -Ggray -Swhite -A0/0/1 -X12.5c -Y3.54905c 

REM	Crear y Dibujar Recuadro de zona de estudio en mapa de ubicacion
rem	SET    REGION=-79/-20/-63/-50
	echo -79 -63 >> "temp_Recuadro"
	echo -79 -50 >> "temp_Recuadro"
	echo -20 -50 >> "temp_Recuadro"
	echo -20 -63 >> "temp_Recuadro"

REM	Dibujar rectangulo en zona de estudio
	gmt psxy -R -J -O -K "temp_Recuadro" >> %OUT% -Ap -W0.45p,red -L

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

REM	Borrar archivos temporales
	del temp*
	del gmt.* %OUT%
rem	pause
	
REM	Ejercicios Sugeridos:	
REM	-----------------------------------------------------------------------------------------------------------
REM	Mapa de ubicacion: 
REM	1. Cambiar el tamaño y ubicación del inset (lineas 140 y 141).
REM	2. Cambiar las coordenadas del recuadro de la zona de estudio (líneas 145 a 148).

REM	Leyenda:
REM	1. Cambiar tamaño y ubicación de la leyenda principal (linea 121) y de la auxiliar (128).
REM	2. Cambiar la cantidad de columnas (N en linea 100 y 111).
