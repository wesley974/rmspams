PREFIX ?= /usr/local

do-install:
	install -m 0755 files/rmspams.sh ${PREFIX}/sbin/rmspams
	install -m 0444 files/rmspams.8 ${PREFIX}/man/man8/
	install -m 0444 files/rmspams.conf.5 ${PREFIX}/man/man5/
	install -d -m 0755 ${PREFIX}/examples/rmspams/
	install -m 0444 examples/* ${PREFIX}/examples/rmspams/

.MAIN: do-install
