plot sin(x) w l,cos(x) w p
set title "Funciones basicas"
set ylabel "Rango"
set xlabel "Grados"
set terminal eps
set output "imagen.eps"
replot
