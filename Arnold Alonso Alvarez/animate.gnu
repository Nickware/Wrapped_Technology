set title 'w'
set xlabel 'w'
set ylabel 'w'
set xr[1:2]
set yr[-1:1]
set grid
plot cos(x - i*dt) w l lt 1 lw 1.5 title sprintf('t=%i',i)
i=i+1
if (i < n) reread
