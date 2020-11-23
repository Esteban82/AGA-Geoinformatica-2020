ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Titulo del mapa
	SET	title=EJ21.2_Mapa_Sismicidad_II
	echo %title%
 
REM	Region Geografica
	SET	REGION=-76/-61/-36/-28

REM	Proyeccion Cilindrica: (M)ercator
	SET	PROJ=M15c

REM	Base de datos de GRILLAS
	SET	DEM="GMRTv3_6.grd"

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	CUT=temp_%title%.grd
	SET	color=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.grd

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

REM	-----------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Recortar Grilla
	gmt grdcut "%DEM%" -G%CUT% -R

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A). 
	gmt grdgradient "%CUT%" -Ne0.6 -A270 -G%SHADOW%

REM	Crear CPT Mapa Fondo 
	gmt makecpt -T-11000,0,9000 -Cdodgerblue2,white > %color%

REM	Dimensiones Mapa
	gmt mapproject -R -J -W
rem	pause

REM	Crear Imagen a partir de grilla con sombreado
	gmt grdimage -R -J -O -K %CUT% -C%color% -I%SHADOW% >> %OUT%

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias, Estados, etc. N3: limites marítimos (Nborder[/pen])
	gmt pscoast -R -J -O -K >> %OUT% -Df -N1/0.30 
	gmt pscoast -R -J -O -K >> %OUT% -Df -N2/0.25,-.

REM	Mapear sismos
REM	********************************************************************
REM	Info de los Sismos para saber profundidad maxima
	gmt info "E:\Facultad\Datos_Geofisicos\Sismicidad\USGS\query_*.csv" -h1
	pause

REM	Crear cpt para sismos 
	gmt makecpt > "temp_seis.cpt" -Crainbow -T0/300 -Z -I

REM	Dibujar. Tamaño fijo. Color según profundidad o color fijo
rem	gmt psxy -R -J -O -K "Sismos_Input\query_*.csv" -h1 -i2,1,3 >> %OUT% -Sc0.05 -C"temp_seis"
	gmt psxy -R -J -O -K "Sismos_Input\query_*.csv" -h1 -i2,1   >> %OUT% -Sc0.05 -Gdimgray

REM	Mecanismos_Focales. Datos Global CMT. Tamaño Proporcional a la magnitud (-M: Tamaño Homogeneo)
	gmt psmeca -R -J -O -K "Mecanismos_Focales\CMT_*.txt" >> %OUT% -Sd0.12/0 -Gblack

REM	*********************************

REM	Filtrar Sismos y Mecanismos Focales por Region2
REM	********************************************************************

REM	Definir Perfil A - A'
	echo -74	-29	A  >  "temp_perfil"
	echo -64	-33	A' >> "temp_perfil"

REM	Filtrar dentro del area. A 100 km del perfil.
	gmt select "Sismos_Input\query_*.csv"        -h1 -i2,1,3 > "temp_sismos" -L"temp_perfil"+d100k+p -fg
	gmt select "Mecanismos_Focales\CMT_*.txt"                > "temp_CMT"    -L"temp_perfil"+d100k+p -fg 
rem	pause

REM	Plotear 
	gmt psxy   -R -J -O -K "temp_sismos" >> %OUT% -Sc0.05   -C"temp_seis"
	gmt psmeca -R -J -O -K "temp_CMT"    >> %OUT% -Sd0.12/0 -Gorange

REM	*********************************
REM	Plates Project: Limite de Placas
	gmt psxy -R -J -O -K "Datos\trench.gmt"    -A  >> %OUT% -W0.4,darkgreen -Sf0.75/0.2+l+t -Gdarkgreen

REM	Dibujar Perfil y Texto (segun circulo maximo)
	gmt psxy   -R -J -O -K >> %OUT% "temp_perfil" -Wthin
	gmt pstext -R -J -O -K >> %OUT% "temp_perfil" -D0/0.2c -F+f9

REM	*********************************************

REM	Dibujar color ramp
	gmt psscale -R -J -O -K -C"temp_seis.cpt" >> %OUT% -DjRB+o1.5c/0.5+w-4.5/0.618c -Ba+l"Profundidad (km)" -F+gwhite+p+s --MAP_FRAME_PEN=thinner

REM	Dibujar Escala en -Lg Lon0/Lat0, calculado en meridiano (+c), ancho (+w), elegante(+f)
	gmt psbasemap -R -J -O -K >> %OUT% -Ln0.7/0.06+c-32+w200k+l+f

REM	Dibujar frame (-B): Anotaciones (a), frame (f), grilla (g)
	gmt psbasemap -R%REGION% -J -O -K >> %OUT% -Bxaf -Byaf 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -A -Tg

	pause
rem	del temp* gmt.*
	del %OUT%
