#!/bin/bash
#Richard de la rosa
#07/04/2017
echo "mostrar la grafica"
rm *.gnu

for ((i=-360; i<360;i++)); do echo -e "set yrange [-360:360] ;plot $i*sin(x) \n " ; done | gnuplot -persist
for ((i=360; i<360;i++)); do echo -e "set sample 500; set yrange [-360:360] ;plot $i*sin(x) \n " ; done | gnuplot -persist
