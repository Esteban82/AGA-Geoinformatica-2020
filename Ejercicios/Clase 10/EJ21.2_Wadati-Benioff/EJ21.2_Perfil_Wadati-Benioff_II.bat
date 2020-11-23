ECHO OFF
cls

REM	Define map
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ21.2_Perfil_Wadati-Benioff_II
	echo %title%
	
REM	Dimensiones del Grafico (en cm): Ancho (L), Altura inferior (H1) y arriba (H2)
	SET	L=15
	SET	H1=5
	SET	H2=2.5

REM	Coordendas iniciales (1) y finales del perfil (2)
	SET	Long1=-74
	SET	Long2=-64
	SET	Lat1=-29
	SET	Lat2=-33

REM	Distancia perpendicular al pefil (en km) y rango de profundidades del perfil (en km)
	SET	Dist_Perfil=100
	SET	DepthMin=0
	SET	DepthMax=300

REM	Base de datos de GRILLAS
	SET	DEM="GMRTv3_6.grd"

REM	comandos adicionales
	SET	OUT=%title%.ps

REM	Parametros Generales
REM	-----------------------------------------------------------------------------------------------------------
REM	Sub-seccion FUENTE
	gmtset FONT_ANNOT_PRIMARY 8,Helvetica,black
	gmtset FONT_LABEL 8,Helvetica,black

REM	Sub-seccion FORMATO
	gmtset FORMAT_GEO_MAP ddd:mm:ssF

REM	Sub-seccion GMT
	gmtset GMT_VERBOSE w

REM	Sub-seccion MAPA
	gmtset MAP_FRAME_TYPE fancy
	gmtset MAP_FRAME_WIDTH 0.1
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0
	gmtset MAP_SCALE_HEIGHT 0.1618
	gmtset MAP_TICK_LENGTH_PRIMARY 0.1

REM	Sub-seccion PS
	gmtset PS_MEDIA A3

REM	*********************************************************************************************************
REM	GRAFICO INFERIOR
REM	*********************************************************************************************************

REM	Perfil: Crear archivo para dibujar perfil (Long Lat)
REM	Definir Perfil
	echo %Long1% %Lat1% >  "temp_perfil"
	echo %Long2% %Lat2% >> "temp_perfil"

REM	Interpolar: Remuestrear perfil con datos de posicion geográfica cada 200 m (-I). Lineas siguen circulo máximo.
	gmt sample1d "temp_perfil" -I0.2k > "temp_sample1d"

REM	Distancia: Agregar columna (3°) con distancia del perfil en km (-G+a+uk) calculadas en base al elipsoide (-je)
	gmt mapproject "temp_sample1d" -G+a+uk -je > "temp_track"

REM	Muestrear grilla (-G) en las posiciones geograficas del perfil. Datos en 4° columna.
	gmt grdtrack "temp_track" -G%DEM% > "temp_data"

REM	Informacion: Ver datos del Archivo para crear el gráfico. 3° Columna datos en KM. 4° Columna datos de Topografia.
	echo N datos   LongMin/Max    LatMin/Max    Distancia Perfil      TopoMin/Max
	gmtinfo "temp_data"
	pause

REM	Definir KM (longitud) y rango de alturas de los datos de terminal
	SET	KM=1052.32
	SET	TopoMin=-7
	SET	TopoMax=5
	
REM	Grafico inferior (Longitud vs Profundidad) con sismos y mecanismos focales
REM	-----------------------------------------------------------------------------------------------------------

REM	Datos del perfil segun gmtinfo
	SET	REGION=0/%KM%/%DepthMin%/%DepthMax%

REM	Crear Grafico
	gmt psxy -JX%L%/-%H1% -R%REGION% -T -K -P > %OUT%

REM	Eje X (Sn) e Y
	gmt psbasemap -R -J -O -K  >> %OUT% -Bxaf+l"Distancia (km)" -Byaf+l"Profundidad (km)" --MAP_FRAME_AXES=wESn

REM	Filtrar Sismos y Mecanismos Focales por Region2
REM	********************************************************************

REM	Crear paleta de colores para magnitud de sismos
	gmt makecpt > "temp_seis.cpt" -Crainbow -T0/300 -Z -I

REM	Filtrar y Proyectar los Sismos al perfil/circulo máximo. -Q: Datos geograficos (grados, km). -Lw: Datos hasta los bordes. -S: Ordenada segun distancia
	gmt project "Sismos_Input\query_*.csv" -h1 -i2,1,3 -C%Long1%/%Lat1% -E%Long2%/%Lat2% -W-%Dist_Perfil%/%Dist_Perfil%k -Lw -S -Q > "temp_sismos_project"

REM	Plotear Sismos en perfil distancia vs profundidad
	gmt psxy    -R -J -O -K "temp_sismos_project" >> %OUT% -C"temp_seis" -Sc0.05c -i3,2,2

REM	Filtrar Mecanismos Focales
	gmt select "Mecanismos_Focales\CMT_*.txt" > "temp_CMT" -L"temp_perfil"+d%Dist_Perfil%k+p -fg 

REM	Plotear Mecanismos Focales
	gmt pscoupe -R -J -O -K "temp_CMT" >> %OUT% -Sd0.15/0 -Gred -M -Aa%Long1%/%Lat1%/%Long2%/%Lat2%/90/10000/%DepthMin%/%DepthMax%f -Q

REM	*****************************************************************************************************************
REM	Calcular Exageracion Vertical
REM	--------------------------------------------------------------
REM	Factor escala para eje Horizontal(FH) y Vertical (FV) para convertir entre unidades del gráfico (cm) y reales (m, km). 
REM	km-cm=100000, m-cm=100
	SET	FH=100000
	SET	FV=100000

REM 	Guardar Variables para calculos
	echo %DepthMax% > "temp_Max"
	echo %DepthMin% > "temp_Min"
	echo %H1%  > "temp_H"
	echo %KM%  > "temp_KM"
	echo %L%   > "temp_L"

REM	Calcular Exageracion Vertical y Graficar en el perfil
	gmt math "temp_KM" "temp_L" DIV %FH% MUL = "temp_Esc_Hz"
	gmt math "temp_Max" "temp_Min" SUB "temp_H" DIV %FV% MUL = "temp_Esc_Ve"
	echo Exageracion Vertical =
	gmt math "temp_Esc_Hz" "temp_Esc_Ve" DIV =
	pause

REM	AGREGAR Datos de la terminal
	echo Ex.Vert. = 1.17           | gmt pstext -R -J -O -K -F+cBR+f9p -Gwhite -W1 >> %OUT%

REM	*********************************************************************************************************
REM	GRAFICO SUPERIOR
REM	*********************************************************************************************************
	
REM	Hacer Grafico (psbasemap) y dibujar variables (psxy)
REM	-----------------------------------------------------------------------------------------------------------
	SET	REGION=0/%KM%/%TopoMin%/%TopoMax%

REM	Crear Grafico
	gmt psxy -JX%L%/%H2% -R%REGION% -T -K -O >> %OUT% -Y%H1%

REM	Dibujar Ejes XY
	gmt psbasemap -R -J -O -K >> %OUT% -Bxf -Byaf+l"Elevaciones (km)" --MAP_FRAME_AXES=wESn

REM	Dibujar datos de Distancia y elevaciones (pasado de m a km) (columnas 3 y 4; -i2,3)
	gmt psxy -R -J -O -K "temp_data" >> %OUT% -W0.5,darkblue -i2,3+s0.001

REM	*****************************************************************************************************************
REM	Calcular Exageracion Vertical
REM	--------------------------------------------------------------
REM	Factor escala para eje Horizontal(FH) y Vertical (FV) para convertir entre unidades del gráfico (cm) y reales (m, km). 
REM	km-cm=100000, m-cm=100
	SET	FH=100000
	SET	FV=100000

REM 	Guardar Variables para calculos
	echo %TopoMax% > "temp_Max"
	echo %TopoMin% > "temp_Min"
	echo %H2%  > "temp_H"
	echo %KM%  > "temp_KM"
	echo %L%   > "temp_L"

REM	Mostrar en Terminal
	gmt math "temp_KM" "temp_L" DIV %FH% MUL = "temp_Esc_Hz"
	gmt math "temp_Max" "temp_Min" SUB "temp_H" DIV %FV% MUL = "temp_Esc_Ve"
	echo Exageracion Vertical =
	gmt math "temp_Esc_Hz" "temp_Esc_Ve" DIV =
	pause

REM	Datos terminal
	echo Ex.Vert. = 14.6  | gmt pstext -R -J -O -K -F+cBR+f9p -Gwhite -W1 >> %OUT%

REM	*******************************************************************

REM	Coordenadas Perfil (A, A')
	echo A  | gmt pstext -R -J -O -K -F+cTL+f12p -Gwhite -W1 >> %OUT%
	echo A' | gmt pstext -R -J -O -K -F+cTR+f12p -Gwhite -W1 >> %OUT%

REM	Convert PostScript (PS) into another format: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
REM	-----------------------------------------------------------------------------------------------------------
	gmt psxy -J -R -O -T >> %OUT%
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
REM	-----------------------------------------------------------------------------------------------------------
rem	del gmt.* temp_* %OUT%
	pause
