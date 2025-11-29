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
# Expected: Connection refused (bukan Elf/Manusia)
P