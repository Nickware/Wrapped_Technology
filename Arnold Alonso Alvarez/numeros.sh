#!/bin/bash
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# Author:       Arnold Alonso Alvarez <nutty.blood@gmail.com>   *
# Update:       2017-05-12 14:33                                *
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#Removiendo Scripts generados anteriormente
rm script.gnu
rm animate.gnu
#Limpiar consola
clear

echo "================================================================================"
echo "                      Gif Para Funciones Trigonometricas                        "
echo "================================================================================"

read -p "ingrese function 1:           " fun1
read -p "ingrese nombre de la grafica: " name
read -p "ingrese nombre del eje x:     " namex
read -p "ingrese nombre del eje y:     " namey
read -p "ingrese n(frames):            " n
read -p "ingrese nombre del gif:       " name2
read -p "rango inferior en x:          " rx1
read -p "rango superior en x:          " rx2
read -p "rango inferior en y:          " ry1
read -p "rango superior en y:          " ry2
echo "================================================================================"
echo "Se ha generado un gif llamado" $name2".gif en esta misma carpeta"
echo "================================================================================"

#generando Gif
echo "set term gif animate" >> script.gnu
echo "set output '"$name2".gif'" >> script.gnu
echo "n = "$((n)) >> script.gnu
echo "dt = 2*pi/"$((n)) >> script.gnu
echo "i = 0" >> script.gnu
echo "load 'animate.gnu'" >> script.gnu
echo "set output" >> script.gnu

#definicion de la grafica
echo "set title '"$name"'" >> animate.gnu
echo "set xlabel '"$namex"'" >> animate.gnu
echo "set ylabel '"$namey"'" >> animate.gnu
echo "set xr["$((rx1))":"$((rx2))"]" >> animate.gnu
echo "set yr["$((ry1))":"$((ry2))"]" >> animate.gnu
echo "set grid" >> animate.gnu
echo "plot "$fun1"(x - i*dt) w l lt 1 lw 1.5 title sprintf('t=%i',i)" >> animate.gnu
echo "i=i+1" >> animate.gnu
echo "if (i < n) reread" >> animate.gnu

#ejecutando gnuplot
gnuplot script.gnu
