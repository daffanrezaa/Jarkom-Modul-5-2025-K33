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