echo "Programa grafica funciones matematicas"
echo "-------------Warning------------------"
echo "Este programa utiliza sintaxis gnuplot"
rm *.gnu
read -p "Ingrese la primera funcion: " funcion01
read -p "Ingrese la segunda funcion: " funcion02
read -p "Nombre de la grafica: " titulo
read -p "Titulo de la etiqueta de la ordenada: " ordenada
read -p "Titulo de la etiqueta de la abscisa: " abscisa
echo "plot" $funcion01 "w l," $funcion02 "w p" >> script.gnu
echo 'set title "$titulo"' >> script.gnu
echo 'set ylabel "$ordenada"' >> script.gnu
echo 'set xlabel "$abscisa"' >> script.gnu
echo "set terminal eps" >> script.gnu
echo 'set output "imagen.eps"' >> script.gnu
echo "replot" >> script.gnu
gnuplot script.gnu
#ps2pdf imagen.ps imagen.pdf
evince image.eps
