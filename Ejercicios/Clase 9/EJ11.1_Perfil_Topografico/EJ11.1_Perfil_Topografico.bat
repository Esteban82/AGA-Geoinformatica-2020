ECHO OFF
cls

REM	Define map
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ11.1_Perfil_Topografico
	echo %title%
	
REM	Dimensiones del Grafico: Longitud (L), Altura (H).
	SET	L=15
	SET	H=7.5

REM	Base de datos de GRILLAS
	SET	DEM="GMRTv3_2.grd"

REM	comandos adicionales
	SET	OUT=%title%.ps

REM	Parametros Generales
REM	-----------------------------------------------------------------------------------------------------------
REM	Sub-seccion FUENTE
	gmtset FONT_ANNOT_PRIMARY 8,Helvetica,black
	gmtset FONT_LABEL 9,Helvetica,black
	gmtset FONT_TITLE 12,4,Black

REM	Sub-seccion GMT
	gmtset GMT_VERBOSE w

REM	Sub-seccion MAPA
	gmtset MAP_FRAME_AXES WesN
	gmtset MAP_FRAME_WIDTH 1
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0
	gmtset MAP_SCALE_HEIGHT 0.1618
	gmtset MAP_TICK_LENGTH_PRIMARY 0.1

REM	Sub-seccion PROJECCION
	gmtset PROJ_LENGTH_UNIT cm
	
REM	Sub-seccion PS
	gmtset PS_MEDIA A4
	
REM	Calcular Distancia a lo largo de la línea y agregar datos geofisicos
REM	-----------------------------------------------------------------------------------------------------------

REM	Perfil: Crear archivo para dibujar perfil (Long Lat)
	echo -76 -30 > "temp_line"
	echo -46 -40 >> "temp_line"

REM	Interpolar: agrega datos en el perfil cada 0.2 km (-I).
	gmt sample1d "temp_line" -I0.2k > "temp_sample1d"
rem	gmt sample1d "temp_line" -I1k > "temp_sample1d"
rem	gmt sample1d "temp_line" -I10k > "temp_sample1d"
rem	gmt sample1d "temp_line" -I50k > "temp_sample1d"

REM	Distancia: Agrega columna (3°) con distancia del perfil en km (-G+k)
	gmt mapproject "temp_sample1d" -G+k > "temp_track"

REM	Agrega columna (4) con datos extraidos de la grilla -G (altura) sobre el perfil
	gmt grdtrack "temp_track" -G%DEM% > "temp_data" -fg

REM	Informacion: Ver datos del Archivo para crear el gráfico. 3° Columna datos en km. 4° Columna datos de Topografia.
	echo N Datos y Min/Max de Long, Lat, Distancia(km) y Alturas(m)
	gmtinfo "temp_data"
	pause

REM	Hacer Grafico (psbasemap) y dibujar variables (psxy)
REM	-----------------------------------------------------	------------------------------------------------------
REM	Datos del perfil segun gmtinfo
	SET	KM=2937
	SET	Min=-7000
	SET	Max=5000

REM	Crear Grafico
	gmt psxy -JX%L%/%H% -R0/%KM%/%Min%/%Max% -T -K -P > %OUT%

REM	Dibujar Eje X (Sn)
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf+l"Distancia (km)"  --MAP_FRAME_AXES=Sn

REM	Dibujar Eje Y y datos de columnas 3 y 4 (-i2,3)
	gmt psxy -R -J -O -K "temp_data" -i2,3 >> %OUT% -W0.5,blue -Bya2500f500g2500+l"Alturas (m)" --MAP_FRAME_AXES=wE

REM	Coordenadas Perfil (E, O)
	echo NO | gmt pstext -R -J -O -K -F+cTL+f14p -Gwhite -W1 >> %OUT%
	echo SE | gmt pstext -R -J -O -K -F+cTR+f14p -Gwhite -W1 >> %OUT%

REM	*****************************************************************************************************************
REM	Calcular Escala Vertical y Horizontal, y Exageracion Vertical
REM	--------------------------------------------------------------
REM	Factor escala para eje Horizontal(FH) y Vertical (FV) para convertir entre unidades del gráfico (cm) y reales (m, km). 
REM	km-cm=100000, m-cm=100
	SET	FH=100000
	SET	FV=100

REM 	Guardar Variables para calculos
	echo %Max% > "temp_Max"
	echo %Min% > "temp_Min"
	echo %H%   > "temp_H"
	echo %KM%  > "temp_KM"
	echo %L%   > "temp_L"

REM	Mostrar en Terminal
REM	--------------------------------------------------------------
	echo Escala Horizontal =
	gmt math "temp_KM" "temp_L" DIV %FH% MUL = 
	gmt math "temp_KM" "temp_L" DIV %FH% MUL = "temp_Esc_Hz"

	echo Escala Vertical =  
	gmt math "temp_Max" "temp_Min" SUB "temp_H" DIV %FV% MUL =
	gmt math "temp_Max" "temp_Min" SUB "temp_H" DIV %FV% MUL = "temp_Esc_Ve"

	echo Exageracion Vertical =
	gmt math "temp_Esc_Hz" "temp_Esc_Ve" DIV =

	pause

REM	Agregar a figura
REM	-------------------------------------------------------------

REM	Datos terminal
	echo Esc. Hz. = 1:19.580.000 | gmt pstext -R -J -O -K -F+cBL+f9p -Gwhite -W1 >> %OUT%
	echo Esc. Ve. = 1:160.000    | gmt pstext -R -J -O -K -F+cBC+f9p -Gwhite -W1 >> %OUT%
	echo Ex.Vert. = 122          | gmt pstext -R -J -O -K -F+cBR+f9p -Gwhite -W1 >> %OUT%

REM	*****************************************************************************************************************

REM	Convert PostScript (PS) into another format: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
REM	-----------------------------------------------------------------------------------------------------------
	gmt psxy -J -R -O -T >> %OUT%
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp_* gmt.* %OUT%

rem	pause

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Definir otro perfil (coordenadas en lineas 48 y 49).
REM	2. Ajustar los distintos parámetros al nuevo perfil: distancia (linea 71), altura minima y maxima (72 y 73).	
REM	3. Ajustar los valores de las escalas horizontal, vertical y exageracion vertical (lineas 122 a 124).
REM	4. Verificar/modificar que las coordenads de los extremos del perfil sean correctas (lineas 85 y 86). 
REM	5. Aumentar el intervalo de muestreo (a 1, 10, 50 km) del perfil para ver como disminuyen la resolucion del perfil (lineas 53 a 55).
