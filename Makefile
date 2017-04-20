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
	install -m 0755 files/rmspams.sh /usr/local/sbin/rmspams
	install -m 0444 files/rmspams.8 /usr/share/man/man8/
	install -m 0444 files/rmspams.conf.5 /usr/share/man/man5/

.include <bsd.port.mk>