#!/bin/sh
install -m 600 lists/* /etc
install -m 600 pf.conf /etc
/sbin/pfctl -f /etc/pf.conf
install -m 755 rmspams /usr/local/sbin
