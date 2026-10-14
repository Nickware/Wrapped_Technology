#!/bin/bash
#Author 	Daniel Ernesto Aragón Medina
#Date   	2017-03-10
#Versión 	0.0.1

echo "Programa que Gráfica Funciones Matemáticas"
echo "------------------Warning-----------------"
echo "Este programa utiliza sintaxis de Gnuplot"
rm *.gnu
read -p "Ingrese la primera función:" funcion01 >> scrpt.gnu
read -p "Ingrese la segunda función:" funcion02 >> scrpt.gnu
read -p "Nombre de  la Gráfica:" titulo >> scrpt.gnu
read -p "Defina el titulo de la ordenadas:" Ordenada >>scrpt.gnu
read -p "Defina titulo de las abscisas:" Abscisas >> scrpt.gnu
echo "plot" $funcion01 "w l," $funcion02 "w l" >> scrpt.gnu
echo 'set title' $titulo >> scrpt.gnu
echo 'set ylabel' $Ordenada >> scrpt.gnu
echo 'set xlabel' $Abscisas >> scrpt.gnu
echo "set terminal eps" >> scrpt.gnu
echo 'set output "imagen.eps"' >> scrpt.gnu
echo "replot" >> scrpt.gnu
#echo "pause 20" >> scrpt.gnu
gnuplot scrpt.gnu
evince imagen.eps
