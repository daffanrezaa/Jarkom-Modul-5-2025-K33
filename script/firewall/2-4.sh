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



