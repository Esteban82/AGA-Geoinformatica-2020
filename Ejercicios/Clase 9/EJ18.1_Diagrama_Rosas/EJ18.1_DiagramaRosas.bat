ECHO OFF
cls

REM	Variables del Mapa
REM	-----------------------------------------------------------------------------------------------------------

REM	Titulo del mapa
	SET	title=EJ18.1_DiagramaRosas
	echo %title%

	REM	Region: Argentina
	SET	REGION=0/1/0/360

	REM 	Nombre archivo de salida
	SET	OUT=%title%.ps

	gmtset IO_NAN_RECORDS skip
rem	gmtset GMT_LANGUAGE ES
	

REM	Preparar Datos
REM	-----------------------------------------------------------------------------------------------------------
REM	Calcular Azimuth (-AF) y longitud en km (-Gk) y solo exportar esos datos
	gmt mapproject -fg "Datos.txt" -AF -Gk > "temp_rumbo" -o3,2 -s2

REM	Informacion mostrada en terminal
echo n, mean az, mean r, mean resultant length, max bin sum, scaled mean, and linear length sum.
REM	Datos Estadisticos. Ver cantidad de datos (-I) centrado en clase (-D), con 180° de ambiguedad (-T) 
	gmt psrose "temp_rumbo" -I -D -T
rem	gmt psrose "temp_rumbo" -I -D
rem	gmt psrose "temp_rumbo" -I -D -Zu
rem	gmt psrose "temp_rumbo" -I -D -T -Zu
	pause

REM	Dibujar Figura
REM	--------------------------------------------------------------------------------------------------------
REM	Abrir archivo de salida (ps)
	gmt psxy -R%REGION% -JX10 -T -K -P > %OUT%

REM	Grafico 
REM	-----------------------------------------------------------------------------------------------------------
REM	Dibujar rosa. -A: Ancho del sector en grados. -D: Centrado en la clase. -F: No muestra escala. -T: 180 ambiguedad. -Zu:
	gmt psrose "temp_rumbo" -R -O -K >> %OUT% -Gorange -W1p -Bx0.2g0.2 -By30g30 -B+glightblue -LW,E,S,N -F -A10 -S5cn -D -T
rem	gmt psrose "temp_rumbo" -R -O -K >> %OUT% -Gorange -W1p -Bx0.2g0.2 -By30g30 -B+glightblue -LW,E,S,N -F -A10 -S5cn -D
rem	gmt psrose "temp_rumbo" -R -O -K >> %OUT% -Gorange -W1p -Bx0.2g0.2 -By30g30 -B+glightblue -LW,E,S,N -F -A10 -S5cn -D -Zu
rem	gmt psrose "temp_rumbo" -R -O -K >> %OUT% -Gorange -W1p -Bx0.2g0.2 -By30g30 -B+glightblue -LW,E,S,N -F -A10 -S5cn -D -T -Zu

REM	Texto con info
	echo N = 206        | gmt pstext -R1/10/1/10 -JX10 -O -K >> %OUT% -F+cTL -Ya0.375c
	echo Mean Az = 285  | gmt pstext -R1/10/1/10 -JX10 -O -K >> %OUT% -F+cTL 

REM	-----------------------------------------------------------------------------------------------------------
REM	Cerrar el archivo de salida (ps)
	gmt psxy -J -R -T -O >> %OUT%
	
REM	Convertir ps en otros formatos: EPS (e), PDF (f), JPEG (j), PNG (g), TIFF (t)	
	gmt psconvert %OUT% -A -Tg

REM	Borrar archivos temporales
	del temp_* gmt.* %OUT%

REM	Ejercicios sugeridos
REM	-----------------------------------------------------------------------------------------------------------
REM	1. Cambiar al ancho de clase (-A en linea 43) y el tamaño del grafico (-S).
REM	2. Probar alguno de los otros tipos de diagrama de rosa (lineas 44 a 46). 
REM	3. Para el caso anterior, extraer la informacion correspondiente (lineas 30 a 32) y ajustar los valores de N y Mean Az (lineas 49 y 50).
