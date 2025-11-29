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