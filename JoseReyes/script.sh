#!/bin/bash 
#Autor : Jose Reyes 
# Date : 04/07/2017
# Version : 0.0.1

echo "programa que grafica funciones matematicas"
echo ".............warning..............."
echo "este programa usa sintaxis genuplot"
rm *.gnu 
 
read -p "Ingrese la primera funcion:" funcion01
read -p "Ingrese la segunda funcion:" funcion02
read -p "InNgrese un titulo (entre comillas)" titulo 
read -p "Ingrese nombre del eje X" Abscisa 
read -p "Ingrese nombre del eje Y" Ordenada
read -p "Tipo de imagen" tipo
read -p  "Nombre de la imagen" imagen
echo "plot" $funcion01 "w l," $funcion02 "w p">> script.gnu
echo 'set title' $titulo >> script.gnu
echo 'set ylabel' $Ordenada >> script.gnu
echo 'set xlabel' $Abscisa >> script.gnu
echo 'set terminal' $tipo >> script.gnu
echo 'set outpout' $imagen >> script.gnu
echo 'replot' >> script.gnu

gnuplot script.gnu
