MAN=	rmspams.8 rmspams.conf.5

SCRIPT=	rmspams.sh

realinstall:
	${INSTALL} ${INSTALL_COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE} \
		${.CURDIR}/${SCRIPT} ${DESTDIR}${BINDIR}/syspatch

.include <bsd.prog.mk>
