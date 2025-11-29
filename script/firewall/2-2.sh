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