#!/bin/bash

# --- 1. BOOTSTRAP INTERNET & INSTALL ---
# Pancingan IP Sementara (Wajib agar bisa install paket)
ip addr flush dev eth0
ip addr add 10.80.1.210/30 dev eth0
ip link set eth0 up
ip route add default via 10.80.1.209
echo "nameserver 10.80.1.203" > /etc/resolv.conf 

# Install Apache2 dan tools
apt-get update 
apt-get install -y apache2 netcat curl 

# --- 2. CONFIG IP PERMANEN (/etc/network/interfaces) ---
cat > /etc/network/interfaces <<NET
auto lo
iface lo inet loopback

# IronHills Wajib Static (Subnet A6)
auto eth0
iface eth0 inet static
address 10.80.1.210
netmask 255.255.255.252
gateway 10.80.1.209
dns-nameservers 10.80.1.203 8.8.8.8
NET

service networking restart

# --- 3. CONFIG WEB SERVICE & HOSTNAME ---
HOSTNAME=$(hostname)
echo "Welcome to $HOSTNAME" > /var/www/html/index.html
service apache2 restart