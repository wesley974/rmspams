#!/bin/sh
install -m 600 lists/* /etc
install -m 600 pf.conf /etc
/usr/sbin/pfctl -f /etc/pf.conf
install -m 600 rmspams /usr/local/sbin
