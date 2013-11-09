set ylabel "Time per increment (ns)"
set xlabel "# threads"
plot 'embedded.dat' using 1:2 title 'ldstub latency'
