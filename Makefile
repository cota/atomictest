CFLAGS = -O2
CFLAGS += -Wall -Wold-style-definition -Wmissing-prototypes \
	-Wmissing-declarations -Wpointer-arith -Wundef -Wstrict-prototypes
LIBS = -lpthread

all: test

test: test.o
	$(CROSS_COMPILE)$(CC) -o $@ $< $(LIBS)

plot.dat: data.pl test
	./$< > $@

plot.png: plot.plt plot.dat
	gnuplot -e "set term png" $< > $@

plot.txt: plot.plt plot.dat
	gnuplot -e "set term dumb" $< > $@

plot: plot.png

.PHONY: plot

clean:
	$(RM) *.o *.dat
	$(RM) *.png *.txt
	$(RM) test
