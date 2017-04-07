#!/bin/bash
#Author         : Alejanodra Morales
#Date           : 03/24/2017
#Version        : 0.0.1 
echo "Limpiando carpeta de archivos"
rm *.gnu
echo "Programa grafica funciones matematicas"
echo "-------------Warning------------------"
echo "Este programa usa sintaxis gnuplot"
rm *.gnu
read -p "Ingrese la primera funcion: " funcion01
read -p "Ingrese la segunda funcion: " funcion02
read -p "Nombre de la grafica (entre comillas): " titulo
read -p "Titulo de la etiqueta de la ordenada (entre comillas): " ordenada
read -p "Titulo de la etiqueta de la abscisa (entre comillas): " abscisa
read -p "Tipo de imagen: " tipo
read -p "Nombre de la imagen a guardar (entre comillas): " imagen
echo "plot" $funcion01 "w l," $funcion02 "w p" >> script.gnu
echo 'set title' $titulo >> script.gnu
echo 'set ylabel' $ordenada >> script.gnu
echo 'set xlabel' $abscisa >> script.gnu
echo 'set terminal' $tipo >> script.gnu
echo 'set output' $imagen >> script.gnu
echo 'replot' >> script.gnu
gnuplot script.gnu
evince $imagen.$tipo

