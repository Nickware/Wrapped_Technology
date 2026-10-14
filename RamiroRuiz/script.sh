echo "programa que grafica funciones matematicas"
echo "-----------------------WARNING------------------------"
echo "Este programa utiliza sintaxis gnuplot"
rm *.gnu
read -p "Ingrese la primera función: " funcion01
read -p "Ingrese la segunda función: " funcion02
read -p "Nombre de la grafica: " titulo
read -p "Titulo de la etiquta de las ordenada: " ordenada
read -p "Titulo de las absisa: " absisa
echo "plot" $funcion01 "w l," $funcion02 "w p" >> script.gnu
echo 'set title "$titulo"' >> script.gnu
echo 'set ylabel "$ordenada"' >> script.gnu
echo 'set xlabel "$absisa"' >> script.gnu
echo "set terminal eps" >> script.gnu
echo "set output imagen.eps" >> script.gnu
echo "replot" >> script.gnu
gnuplot script.gnu
#ps2pdf imagen.eps imagen.pdf
evince imagen.eps

#!bin/bash
#Author         JOSE RAMIRO RUIZ VARGAS
#Date           2017-03-17
#Versión        2.5.3

