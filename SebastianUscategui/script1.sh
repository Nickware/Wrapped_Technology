#!/bin/bash
#Author:Sebastian Uscategui
#Date:03/24/2017
#Version:0.0.1

echo "Limpiando "
rm *.gnu
echo "Programa que grafica funciones matematicas"
echo "------------Warning--------------------"
echo "Este programa utiliza sintaxis de gnuplot"
rm *.gnu
read -p "Ingrese la primer funcion: " funcion01
read -p "Ingrese la segunda funcion: " funcion02
read -p "Nombre de la grafica: " titulo
read -p "Nombre de la ordenada: " ordenada
read -p "Titulo de las abscisa: " abscisa
read -p "Tipo de imagen: " tipo
read -p "Nombre de la imagen a guardar (entre comillas)" imagen
echo "plot" $funcion01 "w l,"$funcion02 "w p" >> script1.gnu
echo 'set title' $titulo >> script1.gnu
echo 'set ylabel' $ordenada >> script1.gnu
echo 'set xlabel' $abscisa >> script1.gnu
echo 'set terminal' $tipo >>script1.gnu
echo 'set output "imagen.eps"' >>script1.gnu
echo "replot" >>script1.gnu
gnuplot script1.gnu
#ps2pdf *imagen.ps
evince $imagen.$ipo
