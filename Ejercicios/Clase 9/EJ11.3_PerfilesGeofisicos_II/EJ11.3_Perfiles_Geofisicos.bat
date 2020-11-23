ECHO OFF
cls

REM	Define map
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ11.3_Perfiles_Geofisicos
	echo %title%

REM	Datos perfiles. Datos de perfil y region para extraer datos
REM	Perfil: Crear archivo para dibujar perfil (Long Lat)
	echo -76 -30 > "temp_line"
	echo -46 -40 >> "temp_line"

REM	Definir Region que exceda ligeramente el area del perfil para extraer los datos
	SET	REGION=-76.1/-45.9/-40.1/-29.9

REM	Base de datos de GRILLAS
	SET	DEM="GMRTv3_2.grd"
	SET	GRA="grav_29.1.nc"

REM	Grillas Temporales
	SET	TPEN=temp_Pend.grd
			
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
	
REM	Procesar Grillas
REM	-----------------------------------------------------------------------------------------------------------
REM	Grilla de Pendientes	
	gmt grdgradient %DEM% -D -S"temp_mag.grd" -R%REGION% -fg
	gmt grdmath "temp_mag.grd" ATAN R2D = %TPEN%	
	
REM	Grilla Aire Libre
rem	gmt img2grd %GRA% -R%REGION% -G%TGRA% -T1 -I1 -E -S0.1
		
REM	Calcular Distancia a lo largo de la línea y agregar datos geofisicos
REM	-----------------------------------------------------------------------------------------------------------
REM	Interpolar: agrega datos en el perfil cada 0.2 km (-I).
	gmt sample1d "temp_line" -I0.2k > "temp_sample1d"

REM	Distancia: Agregar columna (3°) con distancia del perfil en km (-G+k)
	gmt mapproject "temp_sample1d" -G+k > "temp_track"

REM	Muestrear grilla (-G) en las posiciones geograficas del perfil. Datos en 4° columna.
	gmt grdtrack "temp_track" -G%DEM% -G%TPEN% -G%GRA% > "temp_data"

REM	Informacion: Ver datos del Archivo para crear el gráfico. 3° Columna datos en KM. 4° Columna datos de Topografia.
	echo N Datos y Min/Max de Long, Lat, Distancia(km), Alturas(m), Pendientes y Anomalies de Aire Libre (mGal):
	gmtinfo "temp_data"
	pause

REM	Hacer Grafico (psbasemap) y dibujar variables (psxy)
REM	-----------------------------------------------------------------------------------------------------------
REM	Dimensiones del Grafico: Longitud (L), Altura (H).
	SET	L=15C
	SET	H=7C

REM	Datos del perfil segun gmtinfo
	SET	KM=2937
	SET	Topo=-6200/5000
	SET	Topokm=-6.2/5.0
	SET	Pend=-1/20
	SET	Grav=-169/400

REM	Crear Grafico
	gmt psxy -JX%L%/%H% -R0/%KM%/%Topo% -T -K -P > %OUT%

REM	Dibujar Eje X (Inferior: S)
	gmt psbasemap -R -J -O -K -Bxaf+l"Distancia (km)" -By0 >> %OUT%  --MAP_FRAME_AXES=ewSn

REM	Dibujar Datos 
	gmt psxy -R0/%KM%/%Topo% -J -O -K "temp_data" -i2,3 -W0.5,blue  >> %OUT% 
	gmt psxy -R0/%KM%/%Pend% -J -O -K "temp_data" -i2,4 -W0.5,red   >> %OUT%
	gmt psxy -R0/%KM%/%Grav% -J -O -K "temp_data" -i2,5 -W0.5,green >> %OUT%

REM	Dibujar Ejes de datos
rem	gmt psbasemap -R0/%KM%/%Topo%   -J -O -K -Bya2500f500g2500+l"Topograf\355a (m)" >> %OUT% --FONT_ANNOT_PRIMARY=8,Helvetica,blue  --MAP_FRAME_AXES=E
	gmt psbasemap -R0/%KM%/%Topokm% -J -O -K -Bya2.5f0.5g2.5+l"Alturas (km)"  >> %OUT% --FONT_ANNOT_PRIMARY=8,Helvetica,blue  --MAP_FRAME_AXES=E
	gmt psbasemap -R0/%KM%/%Pend%   -J -O -K -Bya+l"Pendiente (\232)"         >> %OUT% --FONT_ANNOT_PRIMARY=8,Helvetica,red   --MAP_FRAME_AXES=W
	gmt psbasemap -R0/%KM%/%Grav%   -J -O -K -Bya+l"Anomal\355a Aire Libre (mGal)"  >> %OUT% --FONT_ANNOT_PRIMARY=8,Helvetica,green --MAP_FRAME_AXES=E -Xa1.6c
	
REM	Coordenadas Perfil (E, O)
	echo NO | gmt pstext -R -J -O -K -F+cTL+f14p -Gwhite -W1 >> %OUT%
	echo SE | gmt pstext -R -J -O -K -F+cTR+f14p -Gwhite -W1 >> %OUT%

REM	Convert PostScript (PS) into another format: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
REM	-----------------------------------------------------------------------------------------------------------
	gmt psxy -J -R -O -T >> %OUT%
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
REM	-----------------------------------------------------------------------------------------------------------
	pause
	del temp_* %OUT% gmt.*

