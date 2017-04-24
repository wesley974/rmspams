PREFIX ?= /usr/local

do-install:
	install -m 0755 files/rmspams.sh ${PREFIX}/sbin/rmspams
	install -m 0444 files/rmspams.8 ${PREFIX}/man/man8/
	install -m 0444 files/rmspams.conf.5 ${PREFIX}/man/man5/
	install -d -m 0755 ${PREFIX}/share/examples/rmspams/
	install -m 0444 examples/* ${PREFIX}/share/examples/rmspams/

clean:
	rm -f ${PREFIX}/sbin/rmspams
	rm -f ${PREFIX}/man/man8/rmspams.8
	rm -f ${PREFIX}/man/man5/rmspams.conf
	rm -rf ${PREFIX}/share/examples/rmspams

.MAIN: do-install