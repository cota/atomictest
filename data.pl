#!/usr/bin/perl

use warnings;
use strict;
use List::Util qw(max);

my $n_processors = `cat /proc/cpuinfo | grep processor | wc -l`;
my $max_threads = max(8, $n_processors * 2);
my $samples_per_test = 10;

print "#cpus\tns\tstderr\n";

for my $i (1..$max_threads) {
    my @data = ();
    for my $j (1..$samples_per_test) {
	my $num=`./test $i | grep 'ns/access' | perl -pe 's/([0-9]+) .*/\$1/'`;
	push @data, $num + 0;
    }
    my $mean = average(\@data);
    # http://en.wikipedia.org/wiki/Standard_error
    my $stderr = stdev(\@data) / sqrt($samples_per_test);
    print "$i\t$mean\t$stderr\n";
}

# roll our own basic stats to avoid CPAN dependencies
sub average {
    my ($data) = @_;

    if (not @$data) {
	die("Empty array\n");
    }
    my $total = 0;
    foreach (@$data) {
	$total += $_;
    }
    my $average = $total / @$data;
    return $average;
}

# corrected sample standard deviation
# http://en.wikipedia.org/wiki/Standard_deviation
sub stdev {
    my ($data) = @_;

    if (@$data == 1){
	return 0;
    }
    my $average = &average($data);
    my $sqtotal = 0;
    foreach (@$data) {
	$sqtotal += ($average-$_) ** 2;
    }
    my $std = ($sqtotal / (@$data-1)) ** 0.5;
    return $std;
}

