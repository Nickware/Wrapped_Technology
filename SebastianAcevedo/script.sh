#Author 	Sebastian Acevedo Perez
#Date   	2017-03-10
#Versión 	0.0.1

echo "Programa que gráfica funciones matemáticas"
echo "------------------Warning-----------------"
echo "Este programa utiliza sintaxis de Gnuplot"
rm *.gnu
read -p "Ingrese la primera función:" funcion01 >> script.gnu
read -p "Ingrese la segunda función:" funcion02 >> script.gnu
read -p "Nombre de  la Gráfica:" titulo >> script.gnu
read -p "Defina el titulo de la ordenadas:" Ordenada >>script.gnu
read -p "Defina titulo de las abscisas:" Abscisas >> script.gnu
echo "plot" $funcion01 "w l," $funcion02 "w l" >> script.gnu
echo 'set title "$titulo"' >> script.gnu
echo 'set ylabel "$Ordenada"' >> script.gnu
echo 'set xlabel "$Abscisas"' >> script.gnu
echo "set terminal eps" >> script.gnu
echo 'set output "imagen.eps"' >> script.gnu
echo "replot" >> script.gnu
echo "pause 20" >> script.gnu
#ps2pdf imagen.ps imagen.pdf
gnuplot script.gnu
echo "pause 20" >> script.gnu
#ps2pdf *.ps
#evince *.ps
 
