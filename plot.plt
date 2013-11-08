set ylabel "Time per increment (ns)"
set xlabel "# threads"
plot 'plot.dat' using 1:2:3 title 'atomic increment scaling' with errorbars
