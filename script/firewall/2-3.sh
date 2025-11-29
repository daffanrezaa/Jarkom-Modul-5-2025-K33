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