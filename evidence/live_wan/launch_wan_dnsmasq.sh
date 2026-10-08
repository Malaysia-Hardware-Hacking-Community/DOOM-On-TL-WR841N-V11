#!/bin/sh
printf '420696\n' | sudo -S true 2>/dev/null
sudo -n dnsmasq --conf-file=/tmp/routerenum/dnsmasq.conf \
     --pid-file=/tmp/routerenum/dnsmasq.pid \
     --log-facility=/tmp/routerenum/dnsmasq.log </dev/null >>/tmp/routerenum/dnsmasq_err.log 2>&1 &
disown
sleep 1
echo "pid=$(cat /tmp/routerenum/dnsmasq.pid 2>/dev/null)"
pgrep -a dnsmasq