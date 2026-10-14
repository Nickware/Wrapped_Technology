

#git push gead: Development car...
#git init
#git clone -b Development...link
#git status
#git add nom
#git commit -am 
#git push orIgin HEAD Development
#!/bin/bash
#Author         : Alejandra Morales
#Date           : 05/12/2017
#Version        : 0.0.3
echo "Programa que permite realizar operaciones matematicas basicas"
echo "-------------Warning--------------------"
#echo ((n=5/2)) |bc -l
#read -p "Ingrese el primer numero: " num1
#read -p "Ingrese la segunda numero: " num2
#read -p "Que operacion desea realizar" suma
#read -p "operacion matematica ">>bc
#echo $num1/$num2 | bc -l
#para bash,if evaluación, then sies 1, fi si es 0
convert >>imagen.$tipo .gif
gnuplot script.gnu
evince $imagen.$tipo
#plot[0:3]for[n=1:10:2]besj0(n*x)title"J_0(".n."x)"lt n
#plot [0:1]sin(x) wl
#plot [0:2*pi]sin(x)wl
#plot for [j=1:]sin(j*x) wl
#para evaluar echo,((n=$variable))
#´´enviar una función
read -p "Ingrese la primera funcion: " funcion01
read -p "Ingrese la segunda funcion: " funcion02
read -p "Ingrese el rango que desee: " xx
echo $xx >> script.gnu
if [[ $tipo == "gif" ]]
then
echo'set terminal git animate' >>script.gnu
echo´set output´ ´"imagen´.$tipo´"´>>script.gnu
fi
echo'set terminal git animate' >>script.gnu
echo´set output´ ´"imagen´.$tipo´"´>>script.gnu
read -p "Nombre de la grafica (entre comillas): " titulo
read -p "Titulo de la etiqueta de la ordenada (entre comillas): " ordenada
read -p "Titulo de la etiqueta de la abscisa (entre comillas): " abscisa
read -p "Tipo de imagen: " tipo
#read -p "Nombre de la imagen a guardar (entre comillas): " imagen
echo "plot" $funcion01 "w l," $funcion02 "w p" >> script.gnu
echo 'set title' $titulo >> script.gnu
echo 'set ylabel' $ordenada >> script.gnu
echo 'set xlabel' $abscisa >> script.gnu
echo 'set xrange[0:90]' >> script.gnu
echo 'set terminal' $tipo >> script.gnu
#echo 'set output' $imagen >> script.gnu

echo 'set output' '"imagen01'.$tipo'"' >> script.gnu
echo 'replot' >> script.gnu


