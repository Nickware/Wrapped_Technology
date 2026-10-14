set term gif animate
set output 'w.gif'
n = 30
dt = 2*pi/30
i = 0
load 'animate.gnu'
set output
