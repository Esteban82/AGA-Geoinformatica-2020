ECHO OFF
cls

REM	Definir variables del mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ6.2_Mapa_Aspecto_W
	echo %title%

rem	Region: Argentina
	SET	REGION=-72/-64/-35/-30

rem	Proyeccion Mercator (M)
	SET	PROJ=M15c

REM	Variable DEM
	SET	DEM="GMRTv3_1.grd"

REM	Resolucion Datos de GSHHS: (c)ruda, (l)ow, (i)ntermediate, (h)igh, (f)ull o (a)uto
	SET	D=a

REM	Perspectiva  (acimut/elevacion)
    	SET    p=180/90

REM 	Nombre archivo de salida
	SET	OUT=%title%.ps
	SET	CUT=temp_%title%.grd
	SET	color=temp_%title%.cpt
	SET	SHADOW=temp_%title%_shadow.grd

REM	Parametros GMT
REM	-----------------------------------------------------------------------------------------------------------

REM	Sub-seccion MAPA
	gmtset FORMAT_GEO_MAP ddd:mm:ssG
	gmtset MAP_FRAME_AXES WesN
	gmtset MAP_FRAME_TYPE fancy+
	gmtset MAP_FRAME_WIDTH 0.1
	gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0.3	
	gmtset MAP_SCALE_HEIGHT 0.1618
	gmtset MAP_TICK_LENGTH_PRIMARY 0.1

	gmtset GMT_VERBOSE w

REM	Sub-seccion PS
	gmtset PS_MEDIA A0

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
rem	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT% -p%p%

REM	Calcular Grilla de orientacion de Pendientes (aspecto). -D(a): direccion con pendiente-arriba (abajo).
rem	gmt grdgradient -R "%DEM%" -Da -G%CUT% -fg

REM	Extraer informacion de la grilla recortada para determinar rango de CPT
rem	gmt grdinfo %CUT%
	echo Altura grafico (cm):
	gmt mapproject -R -J -Wh
rem	pause

REM	Crear Paleta de Colores. Paleta Maestra (-C), Definir rango (-Tmin/max/intervalo), CPT continuo (-Z)
rem	gmt makecpt -Ccyclic -T0/360/5 -Z > %color% -Ww
rem	gmt makecpt -Ccyclic -T0/360/15    > %color% 
rem	gmt makecpt -Ccyclic -T0/90/5  -Z > %color% -Ww
rem	gmt makecpt -Cyclic -T0/90/5  -Z > %color%

REM	Crear nuevo CPT
rem	gmt makecpt -Ccyclic -T0/180/5   -Z -N >  %color% -G0.5/1 -Ww
rem	pause
rem	gmt makecpt -Ccyclic -T180/360/5 -Z    >> %color% -G0/0.5
rem	pause

REM	Crear nuevo CPT 2
rem	gmt makecpt -Ccyclic -T0/90/5   -Z -N >  %color% -G0.75/1 -Ww
rem	gmt makecpt -Ccyclic -T90/360/5 -Z    >> %color% -G0/0.75

REM	CPT para pintar de azul los valores de 75 a 105 de azul
	gmt makecpt -Cwhite,green,white -T0,90,360 -Z > %color% 
	pause	

REM	Crear Grilla de Pendientes para Sombreado (Hill-shaded). Definir azimuth del sol (-A)
rem	gmt grdgradient -R -G%SHADOW% "%CUT%" -Ne0.5 -A270
rem	gmt grdgradient -R -G%SHADOW% "%DEM%" -Ne0.5 -A270

REM	Crear Imagen a partir de grilla con sombreado
rem	gmt grdimage -R -J -O -K %CUT% -C%color% -p >> %OUT%
rem	gmt grdimage -R -J -O -K %CUT% -C%color% -p >> %OUT% -I%SHADOW% 

REM	Agregar escala vertical a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
rem	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJBC+o0c/0.3+w15/0.618ch     -I -Baf45+l"Orientaci\363n pendiente(\232)"
	gmt psscale -R -J -O -K -C%color% -p >> %OUT% -DJBC+o0c/0.3+w15/0.618ch        -Ba90f45+l"Orientaci\363n pendiente(\232)"

REM	Datos Instituto Geografico Nacional (IGN)
REM	-----------------------------------------------------------------------------------------------------------
REM	Limites Interprovincial
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\linea_de_limite_070111.shp" -Wthinner,black,-.

REM 	Red vial y ferroviaria
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Autopista.gmt"        -Wthinner,black
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\RedVial_Ruta_Nacional.gmt"    -Wthinner,black
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\lineas_de_transporte_ferroviario_AN010.shp"      -Wthinnest,darkred
	
REM	Localidades y Areas Urbanas
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\puntos_de_asentamientos_y_edificios_localidad.shp" -Sc0.08 -Ggray19
	gmt psxy -R -J -O -K -p >> %OUT% "Datos\areas_de_asentamientos_y_edificios_020105.shp"     -Wfaint -Ggreen

REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar frame
	gmt psbasemap -R -J -O -K -p >> %OUT% -Bxaf -Byaf

REM	Pintar areas húmedas: Oceanos (-S) y Lagos (-Cl/)f
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -Sdodgerblue2 -A0/0/1

REM	Dibujar Bordes Administrativos. N1: paises. N2: Provincias/Estados.
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -N1/0.75

REM	Dibujar Linea de Costa (W1)
	gmt pscoast -R -J -O -K -D%D% -p >> %OUT% -W1/faint 

REM	Escala en el mapa centrado en el 88% del eje X y 7.5% del eje Y (n), calculado en meridiano (+c), ancho (+w).
	gmt psbasemap -R -J -O -K -p >> %OUT% -Ln0.88/0.075+c-54+w50k+f+l   

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -R -J -T -O >> %OUT%

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)
	gmt psconvert %OUT% -Tg -A

REM	Borrar archivos temporales
rem	del temp_*
	del gmt.* %OUT%
rem	pause

REM	Ejercicios Sugeridos:
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Combinar la CPT ciclica para obtener un desfasaje en los colores de:
REM	1.A: 180° (usar lineas 67 y 68)
REM	1.B: 270° (usar lineas 71 y 72)
