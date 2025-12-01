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

