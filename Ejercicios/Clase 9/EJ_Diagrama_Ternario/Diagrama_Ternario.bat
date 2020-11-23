echo off
cls

	gmt begin Diagrama_Ternario png
	gmt makecpt -Cturbo -T0/80/10
	gmt ternary "ternary.txt" -R0/100/0/100/0/100 -JX6i -Sc0.1c -C -LWater/Air/Limestone -Baafg+l"Water component"+u" %%" -Bbafg+l"Air component"+u" %%" -Bcagf+l"Limestone component"+u" %%" -B+givory+t"Example data from MATLAB Central"
	gmt end show
pause
