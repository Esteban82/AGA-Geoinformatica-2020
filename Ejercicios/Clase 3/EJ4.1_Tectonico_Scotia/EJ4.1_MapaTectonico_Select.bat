ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ4.1_MapaTectonico_Select
	echo %title%
 
REM	Region Geografica
	SET	REGION=-79/-20/-63/-20
	SET	REGION=-81/-50/-40/-20

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

REM	Nivel de mensajes. (e)rrores, (w)arnings, (i)nformation
	gmtset GMT_VERBOSE w

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Dibujar marco (-B): Anotaciones (a), frame (f)
	gmt psbasemap -R -J -O -K >> %OUT% -Bxaf -Byaf

REM	Dibujar Paises (1 paises, 2 estados/provincias en America, 3 limite maritimo)
	gmt pscoast -R -J -O -K >> %OUT% -D%D% -N1/0.2,-

REM	Dibujar Linea de Costa de Oceano-Continente (nivel 1)
	gmt pscoast -R -J -O -K -D%D% >> %OUT% -W1/thinner

REM	Pintar varios paises con distintos colores. Paraguay, Chile, Uruguay y Bolivia
	gmt pscoast -R -J -O -K >> %OUT% -EPY+gviolet -ECL+gslateblue -EUY+ggreen -EBO+gyellow 

REM	Dibujar Provincias/Departamentos/Estados (-N2) SOLO en Paises seleccionados
REM	******************************************************************************
REM	Crear poligonos de los paises de Chile y Uruguay
	gmt pscoast -R -M > "temp_mask" -ECL,UY

REM	1) Extraer datos de limites N2
rem	gmt pscoast -R -M > "temp_N2" -D%D% -N2

REM	2) Filtrar datos de N2 que estan dentro de (los poligonos) de los paises
rem	gmt select -F"temp_mask" "temp_N2" > "temp_N2_Filtrado.txt"

REM	3) Graficar datos filtrados
rem	gmt psxy -R -J -O -K >> %OUT% -W0.5 "temp_N2_Filtrado.txt"

REM	Pasos 1, 2 y 3 ensamblados
	gmt pscoast -R -M -D%D% -N2 | gmt select -F"temp_mask" | gmt psxy -R -J -O -K >> %OUT% -W0.5

REM	******************************************************************************

REM	Dibujar Sismos
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear cpt para sismos superficiales (0-30 km), someros (30-100 km), intermedios (100 - 300 km) y profundos (300-1000 km)
	gmt makecpt -Cred,orange,green,blue  -T0,30,100,300,1000  > "temp_seis.cpt"

REM	Dibujar Sismos del USGS segun magnitud (-Scpasc), y color segun profundidad (-Ccpt).
rem	gmt psxy -R -J -O -K "Sismos_Input\query*.csv" -h1 >> %OUT% -W0.1 -i2,1,3,4 -Scp  -C"temp_seis"   

REM	Seleccionar datos y graficarlos. -Z: Filtra valores en columna 5 (+c4) entre un minimo y maximo
	gmt select "Sismos_Input\query*.csv" -h1 -Z-/5+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1,3 -Sc1.5p -C"temp_seis"
	gmt select "Sismos_Input\query*.csv" -h1 -Z5/7+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1,3 -St4.0p -C"temp_seis"
	gmt select "Sismos_Input\query*.csv" -h1 -Z7/9+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1,3 -Ss7.5p -C"temp_seis"
	gmt select "Sismos_Input\query*.csv" -h1 -Z9/-+c4 | gmt psxy -R -J -O -K >> %OUT% -W0.1 -i2,1   -Sa20p  -Gdeeppink

REM	Filtrar sismos > 9 y grabarlo en un archivo
rem	gmt select "Sismos_Input\query*.csv" -h1 -Z9/-+c4 > "Sismos_+9.txt" -Vi

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp* gmt.* 
rem	del %OUT%
rem	pause
