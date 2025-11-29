# di Vilya (DHCP Server)
cat <<'EOF' > /root/setup_vilya.sh
#!/bin/bash

# --- 1. BOOTSTRAP INTERNET (Sederhana & Langsung) ---
# Set IP Static sementara (untuk memastikan koneksi internet via Rivendell)
ip addr flush dev eth0
ip addr add 10.80.1.202/29 dev eth0
ip link set eth0 up
ip route add default via 10.80.1.201
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# --- 2. INSTALL SERVICE ---
apt-get update
apt-get install -y isc-dhcp-server 

# --- 3. CONFIG IP PERMANEN (/etc/network/interfaces) ---
cat > /etc/network/interfaces <<NET
auto lo
iface lo inet loopback

# Vilya Wajib Static (Subnet A3)
auto eth0
iface eth0 inet static
address 10.80.1.202
netmask 255.255.255.248
gateway 10.80.1.201
dns-nameservers 10.80.1.203 8.8.8.8
NET

# --- 4. CONFIG DHCP SERVER POOLS (/etc/dhcp/dhcpd.conf) ---
cat > /etc/dhcp/dhcpd.conf <<DHCP
# Config Global
default-lease-time 600;
max-lease-time 7200;
option domain-name-servers 10.80.1.203, 8.8.8.8;

# A. SUBNET LOKAL VILYA (A3) - Deklarasi Wajib
subnet 10.80.1.200 netmask 255.255.255.248 {
}

# B. SUBNET CLIENT A1 (AnduinBanks: Gilgalad & Cirdan)
subnet 10.80.1.0 netmask 255.255.255.128 {
    range 10.80.1.2 10.80.1.126;
    option routers 10.80.1.1;
    option broadcast-address 10.80.1.127;
}

# C. SUBNET CLIENT A2 (Minastir: Elendil & Isildur)
subnet 10.80.0.0 netmask 255.255.255.0 {
    range 10.80.0.2 10.80.0.254;
    option routers 10.80.0.1;
    option broadcast-address 10.80.0.255;
}

# D. SUBNET CLIENT A4 (Wilderland: Khamul)
subnet 10.80.1.192 netmask 255.255.255.248 {
    range 10.80.1.194 10.80.1.198;
    option routers 10.80.1.193;
    option broadcast-address 10.80.1.199;
}

# E. SUBNET CLIENT A5 (Wilderland: Durin)
subnet 10.80.1.128 netmask 255.255.255.192 {
    range 10.80.1.130 10.80.1.190;
    option routers 10.80.1.129;
    option broadcast-address 10.80.1.191;
}
DHCP

# --- 5. APPLY & START SERVICE ---
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server

service networking restart
service isc-dhcp-server restart
EOF

# Jalankan Script Final
bash /root/setup_vilya_simple.sh