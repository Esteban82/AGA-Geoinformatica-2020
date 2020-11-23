	ECHO OFF
	cls

REM	Definir variables de la figura
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo
	SET	title=EJ1.1_Mapamundi
	echo %title%

REM	Proyecciones miscelaneas. Requiere 1 parámetro opcional: (Lon0/). Meridiano central.
REM	Mollweide (W), Hammer (H), Winkle Triple (R), Robinson (N), Eckert IV (Kf) y VI (Ks), Sinusoidal (I), Van der Grinten (V)
REM	Ancho (o alto "h") en cm (c), pulgadas (i) o puntos (p). Ej.: 15 cm de ancho (/15c). 10 cm de alto (/10ch).
rem	SET	PROJ=W0/15c
	SET	PROJ=W-65/15c
rem	SET	PROJ=W-65/10c
rem	SET	PROJ=W-65/8ch
	
REM	Region geografica del mapa (W/E/S/N) d=-180/180/-90/90 g=0/360/-90/90
	SET	REGION=d

REM 	Nombre archivo de salida a partir del titulo (no modificar)
	SET	OUT=%title%.ps

REM	Parametros por Defecto
REM	-----------------------------------------------------------------------------------------------------------

REM	Nivel de mensajes. (e)rrores, (w)arnings, (i)nformation
	gmtset GMT_VERBOSE w

REM	Dibujar mapa
REM	-----------------------------------------------------------------------------------------------------------
REM	Crear encabezado del archivo de salida (ps) y establecer las variables
	gmt psxy -R%REGION% -J%PROJ% -T -K -P > %OUT%

REM	Pintar areas secas (-Gcolor)
	gmt pscoast -R -J -O -K >> %OUT% -A0/0/1 -G200 

REM	Pintar areas húmedas (-Scolor). Oceanos, Mares, Lagos y Rios.
	gmt pscoast -R -J -O -K >> %OUT% -A0/0/1 -Sdodgerblue2

REM	Dibujar Linea de Costa con un ancho (-Wpen) de 0.25 
	gmt pscoast -R -J -O -K >> %OUT% -A0/0/1 -W

REM	Dibujar limite de Paises (N1:pen División administrativa 1, países) 
	gmt pscoast -R -J -O -K >> %OUT% -A0/0/1 -N1/0.2,-

REM	Dibujar marco del mapa (-B). Lineas de grillas (g). 
	gmt psbasemap -R -J -O -K >> %OUT% -B0
rem	gmt psbasemap -R -J -O -K >> %OUT% -Bg

REM	Dibujar paralelos principales y meridiano de Greenwich a partir del archivo paralelos.txt -Ap (lineas siguen paralelos)
	gmt psxy -R -J -O -K "paralelos.txt" >> %OUT% -Ap -W0.50,.-

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps), Crear Trailer.
	gmt psxy -R -J -T -O >> %OUT% 

REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t). -A recorta margenes en blanco.
	gmt psconvert %OUT% -Tg -A

REM	Eliminar archivos temporales
	del %OUT% gmt.*
rem	pause


REM	Ejercicios Sugeridos
REM     ***********************************************************************
REM	1. Cambiar el titulo del grafico (y del archivo de salida).
REM	2. Cambiar ancho de la figura a 10 cm de ancho (10c), y a 8 cm de alto (10ch).
REM	3. Cambiar el tipo de proyección Miscelánea Hammer (H) y Robinson (N).
REM	4. Cambiar el meridiano central a 60. 
REM	5. Cambiar el color para áreas secas (utilizar código R/G/B y C-M-Y-K, grayscale).
REM	6. Cambiar el color para áreas húmedas (utilizar colornames).
REM	7. Cambiar/agregar otros formatos de salida (pdf, eps, tiff)
