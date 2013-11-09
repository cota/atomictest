#!/bin/sh
# Embedded systems do not have bash or perl. This is
# a simpler version of the data.pl script--note that
# it does not compute averages and standard error.

echo -e "# n_threads\tns" > plot.dat

N_CPUS=$(cat /proc/cpuinfo | grep processor | wc -l)
N_TESTS=$(echo "$N_CPUS * 2" | bc -l)
for i in $(seq $N_TESTS); do
    RES=$(./test $i | grep 'ns/access' | sed -r 's/([0-9]+) .*/\1/') && \
	echo -e "$i\t$RES" >> plot.dat
done
