#!/bin/bash
#author: Cristian_Alvarez
#date: 20-03-10
#version 0.01

echo "programa que grafica"
echo "este programa utiliza sintaxis gnuplot"
rm *.gnu

read -p "ingrese el nombre de la grafica" titulo
read -p "ingrese la primera funcion" funcion01
read -p "ingrese la segunda funcion" funcion02
read -p "ingrese la ordenada" ordenada
read -p "ingrese la abscisa" abscisa
echo "plot" $funcion01 "w l," $funcion02 "w p"  >> script.gnu

#echo 'set title' $titulo  >> script.gnu
#echo 'set ylabel' $ordenada  >> script.gnu
#echo 'set xlabel' $abscisa  >> script.gnu
#echo "set terminal postscript" >> script.gnu
#echo 'set output imagen.eps"'  >>  script.gnu
#echo "replot"  >> script.gnu
#echo "pause60" >> script.gnu
gnuplot script.gnu
#evince imagen.eps

