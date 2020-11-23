ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ4.1_MapaTectonico
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
	gmtset	FONT_ANNOT_PRIMARY 8p,Helvetica,Black

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
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Pintar areas húmedas
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -Sdodgerblue2  

REM	Dibujar Linea de Costa de Oceano-Continente (nivel 1)
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -W1/faint

REM	Datos Tectonicos
REM	-----------------------------------------------------------------------------------------------------------
REM	Plates Project: Limite de Placas
	gmt psxy -R -J -O -K "Datos\transform.gmt" >> %OUT% -W0.4,black -Sf1.5/0.25+l+s -Gblack
	gmt psxy -R -J -O -K "Datos\trench2.gmt"    >> %OUT% -W0.4,green -Sf0.75/0.2+l+t -Gorange
	gmt psxy -R -J -O -K "Datos\ridge.gmt"     >> %OUT% -W1.0,red
	gmt psxy -R -J -O -K "Datos\ridge.gmt"     >> %OUT% -W0.4,white

REM	Plates Project: LIPs
rem	gmt psxy -R -J -O -K "Datos\LIPS.2011.gmt" >> %OUT% -Gp300/29
	gmt psxy -R -J -O -K "Datos\LIPS.2011.gmt" >> %OUT% -Gp300/29:BivoryFred3
rem	gmt psxy -R -J -O -K "Datos\LIPS.2011.gmt" >> %OUT% -Gp30/29:BivoryFred3
rem	gmt psxy -R -J -O -K "Datos\LIPS.2011.gmt" >> %OUT% -Gp300/01

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
rem	gmt makecpt -Cred,orange,green,blue  -T0,5,10,300,1000  > "temp_seis.cpt"

REM	Dibujar Sismos del USGS segun magnitud (-Scpasc), y color segun profundidad (-Ccpt).
REM	Color blanco (-Gwhite) y tamaño fijo (-Sc3p)
REM	Color blanco y tamaño variable (segun su magnitud, columna 5)
REM	Color variable (segun profundidad, columna 4) y tamaño fijo (-Sc3p)
REM	Color variable (segun profundidad, columna 4) y tamaño variable (segun su magnitud columna 5)
rem	gmt psxy -R -J -O -K "Sismos_Input\query*.csv" >> %OUT% -W0.1  -Sc3p -Gwhite	
rem	gmt psxy -R -J -O -K "Sismos_Input\query*.csv" -h1 >> %OUT% -W0.1 -i2,1     -Sc3p -Gwhite
rem	gmt psxy -R -J -O -K "Sismos_Input\query*.csv" -h1 >> %OUT% -W0.1 -i2,1,4   -Scp  -Gwhite
	gmt psxy -R -J -O -K "Sismos_Input\query*.csv" -h1 >> %OUT% -W0.1 -i2,1,3   -Sc1p -C"temp_seis"
rem	gmt psxy -R -J -O -K "Sismos_Input\query*.csv" -h1 >> %OUT% -W0.1 -i2,1,3,4 -Scp  -C"temp_seis"   

REM	Seleccionar datos y graficarlos
rem	gmt select "Sismos_Input\query*.csv" -h1 -Z7/-+c4 > subset8.txt -Vi
	gmt select "Sismos_Input\query*.csv" -h1 -Z-/5+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1,3 -Sc1.5p -C"temp_seis"
	gmt select "Sismos_Input\query*.csv" -h1 -Z5/6+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1,3 -Sc3.0p -C"temp_seis"
	gmt select "Sismos_Input\query*.csv" -h1 -Z6/7+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1,3 -Sc4.5p -C"temp_seis"
	gmt select "Sismos_Input\query*.csv" -h1 -Z7/-+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1,3 -Sc6.0p -C"temp_seis"
rem	gmt select dataset.txt -Z10/50 -Z-/0+c4 > subset3.txt

REM	Dibujar Mecanismos Focales
REM	-----------------------------------------------------------------------------------------------------------
REM	Datos Global CMT. Tamaño proporcional a la magnitud (-M: Tamaño Fijo)
rem	gmt psmeca -R -J -O -K "Mecanismos_Focales\CMT_*.txt" >> %OUT% -Sd0.15/0 -Gblack
rem	gmt psmeca -R -J -O -K "Mecanismos_Focales\CMT_*.txt" >> %OUT% -Sd0.15/0 -Gorange
	
REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar Escala en el mapa centrado en -Lg Lon0/Lat0, calculado en meridiano (+c), ancho (+w), elegante(+f), unidad arriba de escala (+l), unidad con los valores (+u)
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-60/-62+c-54+w500k+f+l 
rem	gmt psbasemap -R -J -O -K >> %OUT% -Lg-74/-62+c-54+w500k+f+l 

REM	Dibujar marco (-B): Anotaciones (a), frame (f)
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp* gmt.* %OUT%
	pause
	
REM	-----------------------------------------------------------------------------------------------------------
REM	Ejercicios Sugeridos:
REM	1. Cambiar los patrones de relleno de las LIPS (lineas 61-64)
REM	2. Cambiar los colores de la color palete table (cpt, linea 81) que luego se utiliza para pintar los sismos (segun su profundidad). Modificar los rangos de valores de cpt y los colores asignados.
REM	3. Ver como graficar sismos con tamaño fijo o no (según su magnitud) y de color fijo o no (segun su profundidad). Lineas 88-91. Prestar atencion a las diferencias entre los comandos (-i).
REM	4. En los mecanismos focales, cambiar el color del cuadrante compresivo a naranja (linea para graficar mecanismos focales (linea 97).
REM	5. Cambiar la posicion de la escala grafica para que no se superponga con los sismos (lineas 102 y 103).
