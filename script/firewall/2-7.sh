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

