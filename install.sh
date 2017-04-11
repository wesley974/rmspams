#!/bin/sh
install -m 0755 rmspams /usr/local/sbin
install -d -m 0755 /usr/local/share/examples/rmspams/
install -m 0644 examples/* /usr/local/share/examples/rspams/
