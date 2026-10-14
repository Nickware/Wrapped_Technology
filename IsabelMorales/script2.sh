#!/bin/bash
#Author         : Alejandra Morales
#Date           : 03/20/2017
#Version        : 0.0.2
echo "Limpiando carpeta de archivos"
rm *.gnu
echo "Programa que permite graficar funciones matematicas"
echo "-------------Warning------------------"
echo "Este programa usa sintaxis gnuplot"
read -p "Ingrese la primera funcion: " funcion01,funcion03,funcion05,funcion07
read -p "Ingrese la segunda funcion: " funcion02,funcion04,funcion06,funcion08 
read -p "Nombre de la grafica (entre comillas): " titulo
read -p "Titulo de la etiqueta de la ordenada (entre comillas): " ordenada
read -p "Titulo de la etiqueta de la abscisa (entre comillas): " abscisa
read -p "Tipo de imagen: " tipo
read -p "Nombre de la imagen a guardar (entre comillas): " imagen
echo "Recuerde que cada una de las graficas que visualice estaran en intervalos comprendidos entre: "1.(0°-90°), 2.(91°-180°),3.(181°-270),4.(271°-360°)"
echo "plot" $funcion01 "w l," $funcion02 "w p" >> script.gnu
echo "plot" $funcion03 "w l," $funcion04 "w p" >> script.gnu
echo "plot" $funcion05 "w l," $funcion06 "w p" >> script.gnu
echo "plot" $funcion07 "w l," $funcion08 "w p" >> script.gnu
echo 'set title' $titulo >> script.gnu
echo 'set ylabel' $ordenada >> script.gnu
echo 'set xlabel' $abscisa >> script.gnu
echo 'set terminal' $tipo >> script.gnu
echo 'set output' $imagen >> script.gnu
echo 'replot' >> script.gnu
convert >>imagen.$tipo .gif
gnuplot script.gnu
evince $imagen.$tipo

