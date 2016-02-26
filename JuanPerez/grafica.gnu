f(x)=x**2
plot f(x) w l
set linetype 1 lc rgb "dark-violet" lw 2 pt 0
set title "Ecuacion cuadratica"
set xlabel "Variable (x)"
set ylabel "Funcion f(x)"
unset key
set grid
set terminal png
set output "migrafica.png"
replot
