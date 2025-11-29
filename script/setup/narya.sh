#!/bin/bash

# --- 1. BOOTSTRAP INTERNET & INSTALL BIND9 ---
# Pancingan IP Sementara (Wajib agar apt-get berhasil)
ip addr flush dev eth0
ip addr add 10.80.1.203/29 dev eth0
ip link set eth0 up
ip route add default via 10.80.1.201
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Install Service BIND9 dan tools
apt-get update
apt-get install -y bind9 dnsutils
ln -s /etc/init.d/named /etc/init.d/bind9

# --- 2. CONFIG IP PERMANEN (/etc/network/interfaces) ---
# Mengatur IP Static Narya secara permanen
cat > /etc/network/interfaces <<NET
auto lo
iface lo inet loopback

# Narya Wajib Static (Subnet A3)
auto eth0
iface eth0 inet static
address 10.80.1.203
netmask 255.255.255.248
gateway 10.80.1.201
dns-nameservers 10.80.1.203 8.8.8.8
NET

# reset node

# --- 3. CONFIG BIND9 SERVICE FILES ---
mkdir -p /etc/bind/ # Memastikan direktori konfigurasi ada

# Config Global Options (Forwarder & Listener)
cat > /etc/bind/named.conf.options <<BINDOPTIONS
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-recursion { any; };
    listen-on { any; }; 
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    dnssec-validation auto;
};
BINDOPTIONS

# Tambah Local Zone Declaration
cat >> /etc/bind/named.conf.local <<BINDLOCAL
zone "vilya.local" IN {
    type master;
    file "/etc/bind/db.vilya";
    allow-update { none; };
};
BINDLOCAL

# Buat File Zone (db.vilya) - Menggunakan file yang sudah diperbaiki (Serial 3)
cat > /etc/bind/db.vilya <<BINDDB
\$TTL    604800
@       IN      SOA     narya.vilya.local. root.localhost. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      narya.vilya.local.
@       IN      A       10.80.1.203   
narya   IN      A       10.80.1.203
vilya   IN      A       10.80.1.202
BINDDB

# --- 4. APPLY & START SERVICE ---
service bind9 restart