# di Osgiliath (Router)
eth0: ke NAT -> DHCP
eth1: ke Moria (A8) -> 10.80.1.217
eth2: ke Rivendell (A9) -> 10.80.1.221
eth3: ke Minastir (A10) -> 10.80.1.225 
 
cat <<'EOF' > /root/.bashrc

# --- 1. Basic Setup ---
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 2. Config Internet (eth0) - STATIC MANUAL ---
# Menggunakan IP aman di range NAT GNS3 (biasanya 192.168.122.x)
ip addr add 192.168.122.210/24 dev eth0
ip link set eth0 up

# Pasang Default Gateway (Pintu Keluar Internet)
ip route add default via 192.168.122.1

# Pasang DNS Google
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# --- 3. Config IP Internal (VLSM) ---
# Ke Moria (A8)
ip addr add 10.80.1.217/30 dev eth1
ip link set eth1 up

# Ke Rivendell (A9)
ip addr add 10.80.1.221/30 dev eth2
ip link set eth2 up

# Ke Minastir (A10)
ip addr add 10.80.1.225/30 dev eth3
ip link set eth3 up

# --- 4. Routing Table (Misi 1 No 3) ---
# Routing ke Cabang Kiri (via Moria .218)
ip route add 10.80.1.228/30 via 10.80.1.218
ip route add 10.80.1.208/30 via 10.80.1.218
ip route add 10.80.1.128/26 via 10.80.1.218
ip route add 10.80.1.192/29 via 10.80.1.218

# Routing ke Cabang Tengah (via Rivendell .222)
ip route add 10.80.1.200/29 via 10.80.1.222

# Routing ke Cabang Kanan (via Minastir .226)
ip route add 10.80.0.0/24 via 10.80.1.226
ip route add 10.80.1.232/30 via 10.80.1.226
ip route add 10.80.1.212/30 via 10.80.1.226
ip route add 10.80.1.236/30 via 10.80.1.226
ip route add 10.80.1.0/25 via 10.80.1.226

# --- 5. Firewall SNAT (Misi 2 No 1) ---
# Kita pakai IP 192.168.122.210 yang kita set di atas
# Ini memenuhi syarat "Dilarang Masquerade" karena kita pakai --to-source
iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 192.168.122.210

EOF

# Jalankan Config
source /root/.bashrc

=====================================================
# di Moria (Router)
eth0: Ke Osgiliath (Subnet A8) -> 10.80.1.218
eth1: Ke IronHills (Subnet A6) -> 10.80.1.209
eth2: Ke Wilderland (Subnet A7) -> 10.80.1.229

cat <<'EOF' > /root/.bashrc

# --- 1. Basic Config ---
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 2. IP Address (VLSM) ---
# Ke Osgiliath (Upstream) - Subnet A8
ip addr add 10.80.1.218/30 dev eth0
ip link set eth0 up

# Ke IronHills (Web Server 1) - Subnet A6
ip addr add 10.80.1.209/30 dev eth1
ip link set eth1 up

# Ke Wilderland (Downstream) - Subnet A7
ip addr add 10.80.1.229/30 dev eth2
ip link set eth2 up

# --- 3. Routing Table ---

# Default Gateway (Ke Osgiliath) -> INI KUNCINYA BIAR BISA INTERNET
ip route add default via 10.80.1.217

# Rute ke Subnet di bawah Wilderland (Durin & Khamul)
ip route add 10.80.1.128/26 via 10.80.1.230
ip route add 10.80.1.192/29 via 10.80.1.230

# --- 4. DNS Resolver ---
# Karena IP statis, kita harus set DNS manual biar bisa ping 'google.com'
echo "nameserver 8.8.8.8" > /etc/resolv.conf

EOF

# Jalankan Config
source /root/.bashrc

===================================================
# di Wilderland 
eth0: Ke Moria (Subnet A7) -> 10.80.1.230 
eth1: Ke Durin (Subnet A5) -> 10.80.1.129 
eth2: Ke Khamul (Subnet A4) -> 10.80.1.193 

cat <<'EOF' > /root/.bashrc
# --- 1. Basic Config ---
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 2. IP Address (VLSM) ---
# Ke Moria (Upstream) - Subnet A7
ip addr add 10.80.1.230/30 dev eth0
ip link set eth0 up

# Ke Client Durin - Subnet A5
ip addr add 10.80.1.129/26 dev eth1
ip link set eth1 up

# Ke Client Khamul - Subnet A4
ip addr add 10.80.1.193/29 dev eth2
ip link set eth2 up

# --- 3. Routing Table ---
# Default Gateway (Ke Moria) -> PENTING BUAT INTERNET
ip route add default via 10.80.1.229

# --- 4. DNS Resolver ---
# Set DNS manual agar bisa ping google
echo "nameserver 8.8.8.8" > /etc/resolv.conf

EOF

# Jalankan Config
source /root/.bashrc

==============================================

# di Rivendell
eth0: Ke Osgiliath (Subnet A9) -> 10.80.1.222
eth1: Ke Vilya & Narya (Subnet A3) -> 10.80.1.201

cat <<'EOF' > /root/.bashrc
# --- 1. Basic Config ---
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 2. IP Address (VLSM) ---
# Ke Osgiliath (Upstream) - Subnet A9
ip addr add 10.80.1.222/30 dev eth0
ip link set eth0 up

# Ke Server Area (Vilya & Narya) - Subnet A3
ip addr add 10.80.1.201/29 dev eth1
ip link set eth1 up

# --- 3. Routing Table ---
# Default Gateway (Ke Osgiliath) -> JALUR INTERNET
ip route add default via 10.80.1.221

# --- 4. DNS Resolver ---
echo "nameserver 8.8.8.8" > /etc/resolv.conf

EOF

source /root/.bashrc

==================================================

# di Minastir
eth0: Ke Osgiliath (Subnet A10) -> 10.80.1.226
eth1: Ke Elendil & Isildur (Subnet A2) -> 10.80.0.1
eth2: Ke Pelargir (Subnet A11) -> 10.80.1.233

cat <<'EOF' > /root/.bashrc
# --- 1. Basic Config ---
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 2. IP Address (VLSM) ---
# Ke Osgiliath (Upstream) - Subnet A10
ip addr add 10.80.1.226/30 dev eth0
ip link set eth0 up

# Ke Client Elendil & Isildur - Subnet A2
ip addr add 10.80.0.1/24 dev eth1
ip link set eth1 up

# Ke Pelargir (Downstream) - Subnet A11
ip addr add 10.80.1.233/30 dev eth2
ip link set eth2 up

# --- 3. Routing Table ---
# Default Gateway (Ke Osgiliath) -> JALUR INTERNET
ip route add default via 10.80.1.225

# Rute Statis ke Subnet di Bawah Pelargir (Via IP Pelargir .234)
# A12 (Palantir)
ip route add 10.80.1.212/30 via 10.80.1.234
# A13 (Link Pelargir-AnduinBanks)
ip route add 10.80.1.236/30 via 10.80.1.234
# A1 (Client Gilgalad & Cirdan)
ip route add 10.80.1.0/25 via 10.80.1.234

# --- 4. DNS Resolver ---
echo "nameserver 8.8.8.8" > /etc/resolv.conf

EOF

# Jalankan Config
source /root/.bashrc


======================================================

# di Pelargir
eth0: Ke Minastir (Subnet A11) -> 10.80.1.234
eth1: Ke AnduinBanks (Subnet A13) -> 10.80.1.237
eth2: Ke Palantir (Subnet A12) -> 10.80.1.213

cat <<'EOF' > /root/.bashrc
# --- 1. Basic Config ---
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 2. IP Address (VLSM - REVISI POSISI) ---
# Ke Minastir (Upstream) - Subnet A11
ip addr add 10.80.1.234/30 dev eth0
ip link set eth0 up

# Ke Palantir (Web Server 2) - Subnet A12
ip addr add 10.80.1.213/30 dev eth1
ip link set eth1 up

# Ke AnduinBanks (Downstream) - Subnet A13
ip addr add 10.80.1.237/30 dev eth2
ip link set eth2 up

# --- 3. Routing Table ---
# Default Gateway (Ke Minastir) -> JALUR INTERNET
ip route add default via 10.80.1.233

# Rute ke Subnet di bawah AnduinBanks (Client Gilgalad & Cirdan) via IP AnduinBanks (.238)
ip route add 10.80.1.0/25 via 10.80.1.238

# --- 4. DNS Resolver ---
echo "nameserver 8.8.8.8" > /etc/resolv.conf

EOF

source /root/.bashrc

===============================================================

# di AnduinBanks
eth0: Ke Pelargir (Subnet A13) -> 10.80.1.238
eth1: Ke Gilgalad & Cirdan (Subnet A1) -> 10.80.1.1

cat <<'EOF' > /root/.bashrc
# --- 1. Basic Config ---
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 2. IP Address (VLSM) ---
# Ke Pelargir (Upstream) - Subnet A13
ip addr add 10.80.1.238/30 dev eth0
ip link set eth0 up

# Ke Client Gilgalad & Cirdan - Subnet A1
ip addr add 10.80.1.1/25 dev eth1
ip link set eth1 up

# --- 3. Routing Table ---
# Default Gateway (Ke Pelargir) -> JALUR INTERNET
ip route add default via 10.80.1.237

# --- 4. DNS Resolver ---
echo "nameserver 8.8.8.8" > /etc/resolv.conf

EOF

source /root/.bashrc