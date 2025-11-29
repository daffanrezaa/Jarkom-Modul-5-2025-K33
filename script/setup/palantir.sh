#!/bin/bash

# --- 1. BOOTSTRAP INTERNET & INSTALL ---
# Pancingan IP Sementara
ip addr flush dev eth0
ip addr add 10.80.1.214/30 dev eth0
ip link set eth0 up
ip route add default via 10.80.1.213
echo "nameserver 10.80.1.203" > /etc/resolv.conf 

# Install Apache2 dan tools\
apt-get update 
apt-get install -y apache2 netcat curl

# --- 2. CONFIG IP PERMANEN (/etc/network/interfaces) ---
cat > /etc/network/interfaces <<NET
auto lo
iface lo inet loopback

# Palantir Wajib Static (Subnet A12)
auto eth0
iface eth0 inet static
address 10.80.1.214
netmask 255.255.255.252
gateway 10.80.1.213
dns-nameservers 10.80.1.203 8.8.8.8
NET

# --- 3. CONFIG WEB SERVICE ---
HOSTNAME=$(hostname)
# Buat index.html sesuai modul: "Welcome to {hostname}"
echo "Welcome to $HOSTNAME" > /var/www/html/index.html

# --- 4. APPLY & START SERVICE ---
service networking restart
service apache2 restart
