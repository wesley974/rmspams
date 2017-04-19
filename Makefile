COMMENT = 		remove spams from a user junk folder and block senders
CATEGORIES = 	mail
DISTNAME = 		rmspams
MAINTAINER = 	Wesley Mouedine Assaby <milo974@gmail.com>

# BSD
PERMIT_PACKAGE_CDROM =	Yes

NO_BUILD = Yes
NO_TEST = Yes

PKG_ARCH = *

install:
	${INSTALL_PROGRAM} ${FILESDIR}/rmspams.sh ${PREFIX}${BINDIR}/rmspams

.include <bsd.port.mk>