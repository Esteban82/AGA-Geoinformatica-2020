	ECHO OFF
rem	cls


REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa     
	SET	title=EJ1.2_Modern_Hemisferico
	echo %title%

REM	Proyecciones acimutales requieren 3 parametros + 1 opcional (lon0/lat0[/horizon]/width
rem	SET	PROJ=G-65/-30/90/15c
	SET	PROJ=G%MOVIE_COL0%/-30/90/14.9c
	SET	PROJ=G-65/%MOVIE_COL0%/90/14.9c
     
REM	Region geografica del mapa (W/E/S/N) d=-180/180/-90/90 g=0/360/-90/90
	SET	REGION=d

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

REM	Parametros por Defecto
REM	-----------------------------------------------------------------------------------------------------------

REM	Sub-seccion GMT
	gmtset GMT_VERBOSE w
	gmtset MAP_FRAME_TYPE plain

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
rem	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%
	gmt begin %title% png 

REM	Pintar areas secas (-G). Resolucion datos full (-Df)
	gmt coast -R%REGION% -J%PROJ% -Df -G200 -Yc -Xc

REM	Dibujar Antartida_Argentina. 
REM	Los meridianos 74° Oeste y 25° Oeste y el paralelo 60° Sur y el Polo Sur.
REM	Crear archivo con coordendas.
	echo -74 -60 >  "temp_Antartida_Argentina"
	echo -74 -90 >> "temp_Antartida_Argentina"
	echo -25 -60 >> "temp_Antartida_Argentina"

REM	Dibujar archivo previo. Borde (-Wpen), Relleno (-Gfill), Lineas siguen meridianos (-Am), Cerrar polígonos (-L)
	gmt plot "temp_Antartida_Argentina" -L -Am -Grosybrown2 -W0.25

REM	Resaltar paises DCW (-E). Codigos ISO 3166-1 alph-2. (AR: Argentina soberana, FK: Malvinas, GS: Georgias del Sur). Pintar de color (+g), Dibujar borde (+p). 
	gmt coast -EAR,FK,GS+grosybrown2

REM	Pintar areas húmedas: Oceanos (-S) y Lagos y Rios (-C).
	gmt coast -Sdodgerblue2 -C200

REM	Dibujar Paises (1 paises, 2 estados/provincias en America, 3 limite maritimo)
	gmt coast -N1/0.2,-

REM	Dibujar Linea de Costa
rem	gmt coast -Df -W1/

REM	Dibujar Ciudades
	gmt plot "Participantes.txt" -Sa0.25 -Gred

REM	Nombre
rem	gmt text "Participantes.txt" -Dx0/0.2c -F+f6p

REM	Agregar Ubicacion de Ciudad
REM	-------------------------------------------------------	
REM	Longitud, Latitud, Nombre
	echo -66.33563 	-33.29501 San Luis > "temp_ciudades"

REM	Dibujar Ciudades
	gmt plot "temp_ciudades" -Sa0.4 -Ggreen 

REM	Nombre
	gmt text "temp_ciudades" -Dx0/0.5c -F+f6p
REM	-------------------------------------------------------

REM	Dibujar marco del mapa 
	gmt basemap -B0 --MAP_FRAME_PEN=thin
rem	gmt psbasemap -Bg

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida
	gmt end

rem	del temp_* gmt.*
