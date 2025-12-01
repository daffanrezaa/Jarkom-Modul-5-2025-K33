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