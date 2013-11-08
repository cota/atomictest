atomic test
===========
Simple test of the scalability of contended atomic operations.
The only test so far tests atomic increments to the same value
from various numbers of threads.

How to run it
-------------
    $ make plot.dat
runs the test for several numbers of threads.

    $ make plot.png plot.txt
plots the data from `plot.dat`.

TODO
----
Add more tests for atomic operations, e.g. test and set.

License
-------
CC0 (Public domain) - see LICENSE file for details.

Contact
-------
Emilio G. Cota <cota@braap.org>
