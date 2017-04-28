#!/bin/bash
#Author		: N.Torres
#Date		: 04/28/2017
#Version	: 0.0.2 
echo "Limpiando carpeta de archivos anteriores"
rm *.gnu
echo "Inicia..."
echo "Programa grafica funciones matematicas"
echo "-------------Warning------------------"
echo "Este programa utiliza sintaxis gnuplot"
rm *.gnu
read -p "Ingrese la primera funcion: " funcion01
read -p "Ingrese la segunda funcion: " funcion02
read -p "Nombre de la grafica (entre comillas): " titulo
read -p "Titulo de la etiqueta de la ordenada (entre comillas): " ordenada
read -p "Titulo de la etiqueta de la abscisa (entre comillas): " abscisa
read -p "Tipo de imagen: " tipo
#read -p "Nombre de la imagen a guardar (entre comillas): " imagen
echo "plot" $funcion01 "w l," $funcion02 "w p" >> script.gnu
echo 'set title' $titulo >> script.gnu
echo 'set ylabel' $ordenada >> script.gnu
echo 'set xlabel' $abscisa >> script.gnu
echo 'set xrange[0:90]' >> script.gnu
echo 'set terminal' $tipo >> script.gnu
#echo 'set output' $imagen >> script.gnu
echo 'set output' '"imagen01'.$tipo'"' >> script.gnu
echo 'replot' >> script.gnu
echo 'set xrange[91:180]' >> script.gnu
echo 'set terminal' $tipo >> script.gnu
#echo 'set output' $imagen >> script.gnu
echo 'set output' '"imagen02'.$tipo'"' >> script.gnu
echo 'replot' >> script.gnu
echo 'set xrange[181:270]' >> script.gnu
echo 'set terminal' $tipo >> script.gnu
#echo 'set output' $imagen >> script.gnu
echo 'set output' '"imagen03'.$tipo'"' >> script.gnu
echo 'replot' >> script.gnu
echo 'set xrange[271:360]' >> script.gnu
echo 'set terminal' $tipo >> script.gnu
#echo 'set output' $imagen >> script.gnu
echo 'set output' '"imagen04'.$tipo'"' >> script.gnu
echo 'replot' >> script.gnu
gnuplot script.gnu
#evince $imagen
convert -delay 10 -loop 0 *.png animation.gif 
