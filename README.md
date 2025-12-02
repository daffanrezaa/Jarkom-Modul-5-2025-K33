## Anggota Kelompok
| No | Nama                       | NRP         |   
|----|----------------------------|-------------|
| 1  | Aditya Reza Daffansyah     | 5027241034  | 
| 2  | I Gede Bagus Saka Sinatrya |	5027241088  | 

# Laporan Resmi Praktikum Jarkom

## Walkthrough Pengerjaan Praktikum Jarkom Modul 5
## Daftar Isi

- [Anggota Kelompok](#anggota-kelompok)
- [Daftar Isi](#daftar-isi)
- [Misi 1](#misi-1)
- [Misi 2](#misi-2)
- [Misi 3](#misi-3)


## Misi 1
### 1. Identifikasi Perangkat
- **Narya: Berfungsi sebagai DNS Server.**
- **Vilya: Berfungsi sebagai DHCP Server.**
- **Web Servers: Palantir  dan IronHills.**
- **Client (Pasukan):**
    * Khamul: 5 host (Target/Burnice).
    * Cirdan: 20 host (Lycaon).
    * Isildur: 30 host (Policeboo).
    * Durin: 50 host (Caesar).
    * Gilgalad: 100 host (Ellen).
    * Elendil: 200 host (Jane).

Gambar Topologi

![topologi](assets/topologi.png)

### 2. VLSM (Pohon Subnet)
Gambar topologi setelah dilakukan pembagian subnet dengan VLSM.

![topologi](assets/topologi_vlsm.png)

Dari data subnet yang telah kita gabungkan pada topologi di atas kita mendapat bahwa terdapat 13 kelompok, dan dibawah ini adalah pembagian IP berdasarkan pengelompokkan subnet di atas. Dan untuk lebih jelas bisa lihat di link berikut **https://excalidraw.com/#json=uqA2CqYnCAyrFBtNo3WwT,xcrSlEBU2auRSjAUqDPNbw**

![tree](assets/Tree.png)

Maka di bawah ini adalah hasil dari pembagian IP nya berdasarkan pohon subnet di atas dan lebih lengkap bisa lihat di link berikut **https://docs.google.com/spreadsheets/d/1rIcpp_mud5bqu82O9zTuyZutwASYB97vlGDWuLZbQYg/edit?usp=sharing**

![ip](assets/ip.png)

Pembagian Rute

![rute](assets/rute.png)



### 3. Konfigurasi Rute

#### **1. router.sh** 
```bash
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
```
* Script ini adalah skrip gabungan yang berisi konfigurasi infrastruktur untuk 7 Router sekaligus (Osgiliath, Moria, Wilderland, Rivendell, Minastir, Pelargir, dan AnduinBanks).

* Fungsi Rute:
   * IP Addressing: Mengatur IP statis pada seluruh interface router sesuai skema VLSM High Efficiency (/30).
   * Routing Statis: Mendaftarkan jalur (Next Hop) menuju seluruh subnet client agar paket data bisa tersampaikan dari ujung ke ujung.
   * Default Route: Mengatur jalur default ke arah Osgiliath (Upstream) untuk akses internet.

* Fungsi Internet (Misi 2.1):
   * Mengaktifkan SNAT (Source NAT) di Osgiliath untuk mengizinkan akses internet tanpa Masquerade .
   * Mengaktifkan ip_forward pada semua router.

### 4. Konfigurasi Service
Bagian ini berfokus pada instalasi dan konfigurasi aplikasi jaringan (Layer 7) seperti DHCP, DNS, dan Web Server. Script ini dijalankan setelah routing dan internet aktif.

#### **1. vilya.sh**
```bash
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
```
* Lokasi: Node Vilya.
* Fungsi:
   * Menginstall isc-dhcp-server.
   * Mengkonfigurasi /etc/dhcp/dhcpd.conf untuk membagikan IP otomatis, Gateway, dan DNS ke subnet Client (A1, A2, A4, A5).

#### **2. narya.sh**
```bash
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
```
* Lokasi: Node Narya.
* Fungsi:
   * Menginstall bind9.
   * Mengatur Forwarders ke Google (8.8.8.8) untuk koneksi internet.
   * Membuat Local Zone agar server internal bisa diakses menggunakan nama domain.

#### **3. palantir.sh**
```bash
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
```

* Lokasi: Node Palantir (Subnet A12).
* Fungsi:
   * Menginstall apache2.
   * Membuat halaman web kustom "Welcome to Palantir".
   * Mengatur IP statis .214 (/30).

#### **4. ironhills.sh**
```bash
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
```
* Lokasi: Node IronHills (Subnet A6).
* Fungsi:
   * Menginstall apache2.
   * Membuat halaman web kustom "Welcome to IronHills".
   * Mengatur IP statis .210 (/30).

#### **5. minastir.sh**
```bash
# --- INSTALL & CONFIG DHCP RELAY ---
# 1. Update dan install service relay
apt-get update
apt-get install -y isc-dhcp-relay

# 2. Tulis konfigurasi ke file default isc-dhcp-relay
cat > /etc/default/isc-dhcp-relay <<RELAY_CONF
# --- DHCP Relay Configuration ---
# IP DHCP Server (VILYA)
SERVERS="10.80.1.202"

# Interface yang mendengarkan request DHCP broadcast (dari Client LAN A2)
INTERFACES="eth1 eth0" 
RELAY_CONF

# 3. Aktifkan service
service isc-dhcp-relay restart
```
* Lokasi: Router Minastir.
* Fungsi: Menginstall isc-dhcp-relay untuk meneruskan permintaan IP dari Client Elendil & Isildur ke Vilya.

#### **6. rivendell.sh**
```bash
# --- INSTALL & CONFIG DHCP RELAY ---
# 1. Update dan install service relay
apt-get update
apt-get install -y isc-dhcp-relay

# 2. Tulis konfigurasi ke file default isc-dhcp-relay
cat > /etc/default/isc-dhcp-relay <<RELAY_CONF
# --- DHCP Relay Configuration ---
# IP DHCP Server (VILYA)
SERVERS="10.80.1.202"

# Interface yang mendengarkan request DHCP broadcast (dari Osgiliath)
INTERFACES="eth0" 
RELAY_CONF

# 3. Aktifkan service
service isc-dhcp-relay restart
```
* Lokasi: Router Rivendell.
* Fungsi: Menginstall isc-dhcp-relay sebagai perantara (Relay) utama yang terhubung langsung ke Vilya.

#### **7. wilderland.sh**
```bash
# --- INSTALL & CONFIG DHCP RELAY ---
# 1. Update dan install service relay
apt-get update
apt-get install -y isc-dhcp-relay

# 2. Tulis konfigurasi ke file default isc-dhcp-relay
cat > /etc/default/isc-dhcp-relay <<RELAY_CONF
# --- DHCP Relay Configuration ---
# IP DHCP Server (VILYA)
SERVERS="10.80.1.202"

# Interface yang mendengarkan request (eth1 & eth2)
INTERFACES="eth1 eth2 eth0" 
RELAY_CONF

# 3. Aktifkan service
service isc-dhcp-relay restart
```
* Lokasi: Router Wilderland.
* Fungsi: Menginstall isc-dhcp-relay untuk meneruskan permintaan IP dari Client Durin & Khamul.

#### **8. anduinbanks.sh**
```bash
# --- INSTALL & CONFIG DHCP RELAY ---
# 1. Update dan install service relay
apt-get update
apt-get install -y isc-dhcp-relay

# 2. Tulis konfigurasi ke file default isc-dhcp-relay
cat > /etc/default/isc-dhcp-relay <<RELAY_CONF
# --- DHCP Relay Configuration ---
# IP DHCP Server (VILYA)
SERVERS="10.80.1.202"

# Interface yang mendengarkan request (eth1)
INTERFACES="eth1 eth0" 
RELAY_CONF

# 3. Aktifkan service
service isc-dhcp-relay restart
```
* Lokasi: Router AnduinBanks.
* Fungsi: Menginstall isc-dhcp-relay untuk meneruskan permintaan IP dari Client Gilgalad & Cirdan.

Dokumentasi:

DHCP 

![dhcp](assets/dhcp.png)

DNS

![dns](assets/dns.png)

Hostname

![hostname](assets/html-hostname.png)

![hostname](assets/index-html.png)


## Misi 2

### 1. Routing Internet dengan `SNAT`
* File Konfigurasi: router.sh (Pada Osgiliath) 
* Misi: Menghubungkan jaringan Aliansi ke Internet (Valinor) tanpa menggunakan target MASQUERADE.
* Penjelasan: Alih-alih menggunakan MASQUERADE (yang dinamis), kami menggunakan SNAT (Source Network Address Translation) yang statis. Kami mengubah alamat IP sumber paket yang keluar dari interface eth0 menjadi IP Publik Osgiliath (192.168.122.210).

### 2. Blokir `ICMP` (ping) ke Vilya
```bash
# di Vilya
cat <<'EOF' >> /root/.bashrc

# --- Misi 2 No 2: VILYA FIREWALL ---

# Bersihkan aturan lama
iptables -F
iptables -X

# 1. Izinkan trafik yang sudah terjalin/terkait (Stateful)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 2. IZINKAN LAYANAN UTAMA (DHCP) - Vilya adalah DHCP Server
# Port 67 UDP harus diizinkan masuk
iptables -A INPUT -p udp --dport 67 -j ACCEPT

# 3. IZINKAN SEMUA TRAFIK KELUAR (Vilya tetap leluasa)
iptables -A OUTPUT -j ACCEPT

# 4. BLOKIR PING (ICMP) INGRESS (Persyaratan Misi)
iptables -A INPUT -p icmp -j DROP

# 5. Set kebijakan default agar semua yang tidak diizinkan di atas di-DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

# --- DNS Resolver (Tambahan, untuk memastikan Vilya bisa resolve) ---
echo "nameserver 10.80.1.203" > /etc/resolv.conf

EOF

# Jalankan Config
source /root/.bashrc

# testing
# Tes Egress di Vilya
ping 10.80.1.201 # gateway -> sukses

# Tes Ingress di Rivendell
ping 10.80.1.202 # IP Vilya -> gagal
```
* File Konfigurasi: 2-2.sh (Pada Vilya) 
* Misi: Melindungi Vilya (DHCP Server) dari pemindaian ping, namun Vilya tetap bisa melakukan ping ke luar.
* Penjelasan:
   * Kami mengizinkan trafik UDP port 67 (DHCP) dan trafik ESTABLISHED agar fungsi server tetap berjalan.
   * Kami memblokir protokol ICMP pada chain INPUT. Ini membuat Vilya tidak membalas ping dari siapapun.
   * Chain OUTPUT dibiarkan terbuka (ACCEPT), sehingga Vilya tetap bisa mengirim ping ke luar.

Dokumentasi:

Tes Gagal

![gagal](assets/2-2_gagal.png)

Tes Sukses

![sukses](assets/2-2_sukses.png)

### 3. Batasi Akses DNS
```bash
# di Narya

cat <<'EOF' >> /root/.bashrc

# --- Misi 2 No 3: Restriksi Akses DNS ---
# Bersihkan tabel FILTER dari aturan lama (kecuali jika sudah di-F sebelumnya)
iptables -F
iptables -X

# 1. Izinkan trafik yang sudah terjalin/terkait (Stateful)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 2. IZINKAN AKSES DARI VILYA (Source IP 10.80.1.202)
# Izinkan UDP dan TCP Port 53 masuk dari Vilya
iptables -A INPUT -p udp -s 10.80.1.202 --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -s 10.80.1.202 --dport 53 -j ACCEPT

# 3. IZINKAN LAYANAN SERVER LAIN (Narya)
# Izinkan Narya mengakses dirinya sendiri (localhost)
iptables -A INPUT -i lo -j ACCEPT

# 4. IZINKAN SEMUA TRAFIK KELUAR (Narya harus bisa forward ke 8.8.8.8)
iptables -A OUTPUT -j ACCEPT

# 5. BLOKIR SEMUA SISA AKSES DNS (dari sumber lain ke Port 53)
# Semua yang bukan Vilya dan bukan established/related akan di-DROP di policy
iptables -A INPUT -p udp --dport 53 -j DROP
iptables -A INPUT -p tcp --dport 53 -j DROP

# 6. Set kebijakan default agar semua yang tidak diizinkan di atas di-DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

EOF

# Jalankan Config
source /root/.bashrc

# testing
# dari Vilya 
nc -zvw 3 10.80.1.203 53 # sukses

# dari Khamul
nc -zvw 3 10.80.1.203 53 # gagal

# hapus akses yang memblokir dns setelah pengecekan
#lihat aturan iptables, cari id yang udp tcp
iptables -L INPUT --line-numbers

# drop udp tcp
iptables -D INPUT 5
iptables -D INPUT 4
```
* File Konfigurasi: 2-3.sh (Pada Narya)
* Misi: Mencegah kebocoran informasi topologi dengan membatasi akses DNS hanya untuk Vilya.
* Penjelasan: Kami menerapkan prinsip Whitelist.
   * Allow Vilya: Mengizinkan paket TCP/UDP pada port 53 HANYA jika Source IP adalah Vilya (10.80.1.202).
   * Allow Localhost: Mengizinkan server mengakses dirinya sendiri.
   * Block All Else: Memblokir akses port 53 dari sumber manapun selain Vilya.

Dokumentasi:

Tes Gagal

![gagal](assets/2-3_gagal.png)

Tes Sukses

![sukses](assets/2-3_sukses.png)

### 4. Filter Akses Berbasis Waktu
```bash
# di IronHills
# Cleanup
iptables -F
iptables -X

# Rule 1: DROP weekdays (Mon-Fri) untuk port 80
iptables -A INPUT -p tcp --dport 80 -m time --weekdays Mon,Tue,Wed,Thu,Fri --kerneltz -j DROP

# Rule 2: ACCEPT Faksi Kurcaci (Durin) - 10.80.1.128/26
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.128/26 -j ACCEPT

# Rule 3: ACCEPT Faksi Pengkhianat (Khamul) - 10.80.1.192/29
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.192/29 -j ACCEPT

# Rule 4: ACCEPT Faksi Manusia (Elendil & Isildur) - 10.80.0.0/24
iptables -A INPUT -p tcp --dport 80 -s 10.80.0.0/24 -j ACCEPT

# Rule 5: DROP sisanya
iptables -A INPUT -j DROP

# Set Policy
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# test berhasil (Sabtu)
# di IronHills
date -s "2025-11-29 10:00:00"

# di Khamul
curl http://10.80.1.210
# nampilin Welcome to IronHills


# test gagal (Misal Rabu)
# di IronHills
date -s "2025-11-26 10:00:00"

# di Khamul
curl http://10.80.1.210
# nampilin Welcome to IronHills
```
* File Konfigurasi: 2-4.sh (Pada IronHills) 
* Misi: Membatasi akses server IronHills hanya pada hari Sabtu dan Minggu.
* Penjelasan: Kami menggunakan modul -m time dengan parameter --weekdays.
   * Aturan pertama secara eksplisit memblokir (DROP) akses ke port 80 pada hari Senin hingga Jumat (Mon,Tue,Wed,Thu,Fri).
   * Jika hari saat ini adalah Sabtu atau Minggu, paket akan melewati aturan drop tersebut dan diizinkan oleh aturan berikutnya (Accept Faksi).

Dokumentasi Hasil

![tanggal](assets/2-4_tanggal.png)

### 5. Filter Akses Berbasis Jam
```bash
# di Palantir

# Cleanup
iptables -F
iptables -X
iptables -P INPUT ACCEPT # Set sementara agar bisa flush

# Aturan Dasar (Tetap)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT # Tambahan: Allow localhost

# 1. ALLOW FAKSI ELF (Source A1) JIKA JAMNYA 07:00 - 15:00
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.0/25 -m state --state NEW \
-m time --timestart 07:00 --timestop 15:00 --kerneltz -j ACCEPT

# 2. ALLOW FAKSI MANUSIA (Source A2) JIKA JAMNYA 17:00 - 23:00
iptables -A INPUT -p tcp --dport 80 -s 10.80.0.0/24 -m state --state NEW \
-m time --timestart 17:00 --timestop 23:00 -j ACCEPT

# 3. DROP SEMUA AKSES WEB LAINNYA (Catch-all)
iptables -A INPUT -p tcp --dport 80 -j DROP

# Set Kebijakan Default (Final Security Stance)
iptables -P INPUT DROP
iptables -P FORWARD DROP


# Test 1: Faksi Elf jam 10:00 (BERHASIL - dalam jam 07:00-15:00)
# di Palantir
date -s "2025-11-26 10:00:00"

# di Gilgalad
curl http://10.80.1.214
# Expected: Welcome to Palantir


# Test 2: Faksi Elf jam 16:00 (DITOLAK - di luar jam 07:00-15:00)
# di Palantir
date -s "2025-11-26 16:00:00"

# di Gilgalad
curl http://10.80.1.214
# Expected: Connection refused


# Test 3: Faksi Manusia jam 20:00 (BERHASIL - dalam jam 17:00-23:00)
# di Palantir
date -s "2025-11-26 20:00:00"

# di Elendil
curl http://10.80.1.214
# Expected: Welcome to Palantir


# Test 4: Faksi Manusia jam 14:00 (DITOLAK - di luar jam 17:00-23:00)
# di Palantir
date -s "2025-11-26 14:00:00"

# di Elendil
curl http://10.80.1.214
# Expected: Connection refused


# Test 5: Faksi lain (misal dari Durin) - DITOLAK kapanpun
# di Palantir
date -s "2025-11-26 10:00:00"

# di Durin
curl http://10.80.1.214
# Expected: Connection refused 
```
* File Konfigurasi: 2-5.sh (Pada Palantir) 
* Misi: Membatasi akses server Palantir berdasarkan jam operasional Ras.
* Penjelasan: Kami menggunakan parameter --timestart dan --timestop untuk menentukan jendela waktu akses.
   * Faksi Elf (A1 - 10.80.1.0/25): Diizinkan pada pukul 07:00 - 15:00.
   * Faksi Manusia (A2 - 10.80.0.0/24): Diizinkan pada pukul 17:00 - 23:00.
   * Semua akses di luar jam dan subnet tersebut akan ditolak oleh aturan Catch-all DROP di akhir script.

Dokumentasi Hasil

![jam](assets/2-5_jam.png)

### 6. Proteksi Port Scanning
```bash
# Palantir - Port Scan Protection

# Cleanup
iptables -F
iptables -X
iptables -P INPUT ACCEPT


# Buat custom chain untuk port scan detection
iptables -N PORTSCAN

# Aturan Dasar
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Port Scan Detection: > 15 port dalam 20 detik
iptables -A INPUT -p tcp -m state --state NEW -m recent --set --name portscan
iptables -A INPUT -p tcp -m state --state NEW -m recent --update --seconds 20 --hitcount 15 --name portscan -j PORTSCAN

# PORTSCAN chain: Log + Block SEMUA (termasuk ICMP)
iptables -A PORTSCAN -j LOG --log-prefix "PORT_SCAN_DETECTED: " --log-level 7 --log-tcp-options --log-ip-options
iptables -A PORTSCAN -j DROP

# ICMP (ping) - cek dulu apakah IP sudah masuk blacklist
iptables -A INPUT -p icmp -m recent --rcheck --name portscan -j DROP
iptables -A INPUT -p icmp -j ACCEPT

# Time-based access untuk web
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.0/25 -m time --timestart 07:00 --timestop 15:00 --kerneltz -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 10.80.0.0/24 -m time --timestart 17:00 --timestop 23:00 --kerneltz -j ACCEPT

# Drop web access lainnya
iptables -A INPUT -p tcp --dport 80 -j DROP

# Default policy
iptables -P INPUT DROP
iptables -P FORWARD DROP

# ===== TESTING =====

# Di Elendil - Install nmap
apt-get update && apt-get install -y nmap

# Test 1: Port scan (akan terdeteksi)
nmap -p 1-100 10.80.1.214

# Test 2: Cek apakah ter-block total
ping -c 3 10.80.1.214
# Expected: 100% packet loss

curl http://10.80.1.214
# Expected: Timeout

nc -zv 10.80.1.214 80
# Expected: Connection timed out


# ===== Monitoring di Palantir =====

# Lihat log
dmesg | grep PORT_SCAN

# Lihat IP yang ter-block
cat /proc/net/xt_recent/portscan

iptables -L PORTSCAN -v -n
```
* File Konfigurasi: 2-6.sh (Pada Palantir) 
* Misi: Mendeteksi dan memblokir serangan Port Scanning (mencoba mengakses >15 port dalam 20 detik).
* Penjelasan: Kami menggunakan modul -m recent untuk melacak perilaku koneksi.
   * Tracking: Setiap koneksi TCP baru didaftarkan ke daftar bernama portscan.
   * Detection: Jika satu IP tercatat melakukan lebih dari 15 koneksi (--hitcount 15) dalam 20 detik (--seconds 20), paket dilempar ke chain khusus PORTSCAN.
   * Punishment: Di chain PORTSCAN, IP penyerang di-log dengan prefix PORT_SCAN_DETECTED dan di-DROP.
   * Block ICMP: Kami juga mengecek daftar portscan pada protokol ICMP. Jika IP sudah terlanjur di-blacklist karena scan TCP, maka PING dari IP tersebut juga akan diblokir.

Dokumentasi Hasil

![block_elendil](assets/2-6_block_elendil.png)

### 7. Limitasi Koneksi
```bash
# di IronHills

# Cleanup
iptables -F
iptables -X

# Rule 1: DROP weekdays
iptables -A INPUT -p tcp --dport 80 -m time --weekdays Mon,Tue,Wed,Thu,Fri --kerneltz -j DROP

# Rule 2-4: REJECT jika connlimit > 3
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.128/26 -m state --state NEW -m connlimit --connlimit-above 3 --connlimit-mask 32 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.192/29 -m state --state NEW -m connlimit --connlimit-above 3 --connlimit-mask 32 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --dport 80 -s 10.80.0.0/24 -m state --state NEW -m connlimit --connlimit-above 3 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

# Rule 5-7: ACCEPT faksi
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.128/26 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 10.80.1.192/29 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s 10.80.0.0/24 -j ACCEPT

# Rule 8: DROP sisanya
iptables -A INPUT -p tcp --dport 80 -j DROP

# Set Policy
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Test di hari Sabtu
# di IronHills
date -s "2025-11-29 10:00:00"


# ===== STRESS TEST =====
# di Khamul (atau client lain)

# Test 1: 5 koneksi sekaligus (3 berhasil, 2 ditolak)
for i in {1..7}; do
    (curl -s http://10.80.1.210 && echo "Request $i: SUCCESS") || echo "Request $i: REJECTED" &
done
```
* File Konfigurasi: 2-7.sh (Pada IronHills) 
* Misi: Mencegah overload dengan membatasi jumlah koneksi aktif.
* Penjelasan: Kami menggunakan modul connlimit untuk menghitung koneksi bersamaan (concurrent).
   * Jika jumlah koneksi dari satu IP melebihi 3 (--connlimit-above 3), paket ke-4 dan seterusnya akan ditolak dengan status REJECT (mengirim sinyal tcp-reset ke pengirim agar koneksi putus seketika).

Dokumentasi Hasil:

![conlimit](assets/2-7_conlimit.png)

### 8. Redireksi Traffic
```bash
# 1. Bersihkan tabel NAT (Pastikan tidak ada aturan lama yang konflik)
iptables -t nat -F

# di Ironhills
iptables -I INPUT 1 -p tcp --dport 5555 -j ACCEPT

# 2. Pasang Aturan DNAT di Chain PREROUTING
# Logika: "Jika paket datang dari VILYA (Src) mau ke subnet KHAMUL (Dst),
#          BELOKKAN tujuannya ke IRONHILLS (10.80.1.210)."

# Source: Vilya (10.80.1.202)
# Original Dest: Subnet Khamul (10.80.1.192/29) -> Pakai subnet agar kena semua IP client
# New Dest: IronHills (10.80.1.210)

iptables -t nat -A PREROUTING -s 10.80.1.202 -d 10.80.1.192/29 -j DNAT --to-destination 10.80.1.210

# Tambahkan Rule SNAT khusus untuk paket "Sihir Hitam" ini
# "Jika paket dari Vilya mau ke IronHills (hasil DNAT), ganti sumbernya jadi Saya (Wilderland)"
iptables -t nat -A POSTROUTING -s 10.80.1.202 -d 10.80.1.210 -j SNAT --to-source 10.80.1.230

# 3. Testing Aturan

# di IronHills 
nc -l -p 5555

# di Khamul
nc -l -p 5555

# di Vilya
echo "Pesan Rahasia untuk Khamul" | nc -w 1 10.80.1.194 5555
```
* File Konfigurasi: 2-8.sh 
* Misi: Membelokkan paket dari Vilya yang menuju Khamul ke IronHills.
* Penjelasan: Kami menggunakan DNAT (Destination NAT) pada tabel nat chain PREROUTING.
   * Kondisi: Jika Paket berasal dari Vilya (-s 10.80.1.202) DAN Tujuannya adalah Subnet Khamul (-d 10.80.1.192/29).
   * Aksi: Ubah tujuan paket (--to-destination) menjadi IP IronHills (10.80.1.210).
   * Akibatnya, Vilya merasa mengirim data ke Khamul, namun data tersebut sebenarnya diterima oleh IronHills.

Dokumentasi Hasil:

![sihir](assets/2-8_sihir.png)

## Misi 3

### 1. Isolasi Khamul
```bash
# 1. Blokir trafik DARI Khamul (Source)
# Mencegah Khamul mengirim paket keluar (Internet, Server, Client lain)
iptables -I FORWARD 1 -s 10.80.1.192/29 -j DROP

# 2. Blokir trafik MENUJU Khamul (Destination)
# Mencegah siapa pun mengirim paket ke Khamul
iptables -I FORWARD 1 -d 10.80.1.192/29 -j DROP

# 3. testing
# di Khamul
ping -c 3 8.8.8.8
# packet loss

nc -zvw 2 10.80.1.202 53
# timed out

# di Durin
ping -c 3 8.8.8.8
# aman
```
* File Konfigurasi: 3-1.sh (Pada Router Wilderland) 
* Misi: Memutus total akses jaringan subnet Khamul karena pengkhianatan.
* Penjelasan: Karena Wilderland adalah gateway bagi Khamul, blokir paling efektif dilakukan pada chain FORWARD. Chain ini menangani paket yang lewat melalui router.
   * Block Egress: Memblokir semua paket yang berasal dari (-s) subnet Khamul (10.80.1.192/29).
   * Block Ingress: Memblokir semua paket yang menuju ke (-d) subnet Khamul.
    -   * Kami menggunakan spesifik subnet /29 agar subnet Durin (yang ada di router yang sama) tidak ikut terblokir.

Dokumentasi Hasil

![isolasi](assets/3-1.png)
