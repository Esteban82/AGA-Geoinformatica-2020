	ECHO OFF
	cls
	
REM	Lista de Valores: Archivo con los valores que se usaran para el script principal. Valor minimo y maximo e intervalos.
	gmt math -T0/359/1   -o1 T = "temp_col0.txt"
rem	gmt math -T-80/-50/0.5   -o1 T = "temp_col0.txt"
rem	gmt math -T-80/-50/20   -o1 T = "temp_col0.txt"
rem	gmt math -T-90/269/1 -o1 T = "temp_col0.txt"
	pause
	gmt math -T-359/0/1 -o1 T -1 MUL = "temp_col0.txt"
	pause

REM	Movie: Crear figuras y animacion. D: Frame per second (fps). C: ancho, alto y dpu. Z: Borra frames.
REM	A: Archivo GIF. -N: Nombre de la carpeta con archivos temporales -T
rem	gmt movie "EJ1.2_Modern_Hemisferico.bat" -N"TierraGirando" -T"temp_col0.txt" -C15cx15cx100 -Fmp4 -D12 -Vi -Agif -Z
	gmt movie "EJ1.2_Modern_Hemisferico.bat" -N"Tierra" -T"temp_col0.txt" -C15cx15cx100 -Fmp4 -D15 -Vi
rem	pause

REM	Reusar figuras: con ffmpeg
REM	-framerate: figuras por segundo (fps)
REM	-i: Carpeta con archivos y Archivos 
rem	ffmpeg -loglevel warning -f image2 -framerate 24 -y -i "Tierra\Tierra_%%01d.png" -vcodec libx264 -pix_fmt yuv420p "Tierra_24fps.mp4"

REM	Borrar Temporales
	del temp_* gmt.*
rem	pause

REM	Apagar (-s) o Hibernar (/h) PC
rem	shutdown -s 
rem	shutdown /h

REM	Ejercicios sugeridos
REM	-------------------------------------------------------------------
REM	1. Cambiar el intervalo de los frames (60 de la línea 6).
REM	2. Cambiar el fps (linea 12) a 6 y 24. 
REM	3. Editar el script principal (EJ1.2_Modern_Hemisferico.bat) para agregar a otra ciudad.
