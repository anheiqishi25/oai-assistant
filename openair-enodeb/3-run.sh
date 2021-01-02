#!/bin/bash
cd ~/oai/openairinterface5g/
cwd=`pwd`
ip address
echo "Please input network interface name [eg:eth0]:"&& read eth
echo "Please input EPC ip address [eg:192.168.23.130]:" && read epc
sudo ip route add 192.168.61.0/24 via $epc dev $eth
