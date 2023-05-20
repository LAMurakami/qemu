#!/usr/bin/sh
# set-nic-as-bridge-master.sh

set -o nounset # Report error if no $1 command line argument

# Make sure only root can run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

ip link add name br0 type bridge # create bridge
ip link set dev br0 up # bring bridge up
ip address add 10.55.5.$1/8 dev br0 # Add IP address to bridge
ip route append default via 10.55.5.1 dev br0 # add default route to bridge
ip link set enp3s0 master br0 # Set nic as bridge master
sudo ip address del 10.55.5.$1/8 dev enp3s0 # Remove IP address from nic
