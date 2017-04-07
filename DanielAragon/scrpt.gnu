plot sin(x) w l, cos(x) w l
set title "$titulo"
set ylabel "$Ordenada"
set xlabel "$Abscisas"
set terminal eps
set output "imagen.eps"
replot
pause 20
pause 20
