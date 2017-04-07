#!/bin/sh
install -m 600 lists/* /etc
install -m 600 pf.conf /etc
/sbin/pfctl -f /etc/pf.conf
install -m 755 rmspams /usr/local/sbin
cat <<EOF
You should add this entry in your crontab(5)
0 0 * * * /sbin/pfctl -t blacksmtp -T expire 86400
10 0 * * * /sbin/pfctl -t blacksmtp -T show >/etc/blacksmtp
to remove from blacklist old ip addresses.
EOF
