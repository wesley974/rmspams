#!/bin/sh
mv lists/* /etc
mv pf.conf /etc
/usr/sbin/pfctl -f /etc/pf.conf
mv rmspams /usr/local/sbin
