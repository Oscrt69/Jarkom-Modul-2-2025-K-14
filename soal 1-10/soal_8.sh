#!/bin/bash

# SOAL 8: Setup Reverse DNS untuk subnet DMZ (192.218.3.0/24)
# Jalankan di: TIRION (ns1)

echo "=========================================="
echo "SOAL 8: Setup Reverse DNS"
echo "=========================================="
echo ""

# Tambahkan reverse zone di named.conf.local
echo "Updating named.conf.local..."

cat > /etc/bind/named.conf.local << 'EOF'
zone "K14.com" {
    type master;
    file "/etc/bind/zones/db.K14.com";
    notify yes;
    allow-transfer { 192.218.3.3; };
};

zone "3.218.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.218.3";
    notify yes;
    allow-transfer { 192.218.3.3; };
};
EOF

echo "✓ named.conf.local updated"

# Buat reverse zone file
echo ""
echo "Creating reverse zone file..."

cat > /etc/bind/zones/db.192.218.3 << 'EOF'
$TTL    604800
@       IN      SOA     ns1.K14.com. admin.K14.com. (
                         2025101201     ; Serial
                         604800         ; Refresh
                         86400          ; Retry
                         2419200        ; Expire
                         604800 )       ; Negative Cache TTL
;
; Name servers
@       IN      NS      ns1.K14.com.
@       IN      NS      ns2.K14.com.

; PTR records untuk DMZ
2       IN      PTR     ns1.K14.com.
3       IN      PTR     ns2.K14.com.
4       IN      PTR     sirion.K14.com.
5       IN      PTR     lindon.K14.com.
6       IN      PTR     vingilot.K14.com.
EOF

echo "✓ Reverse zone file created"

# Set permissions
chown bind:bind /etc/bind/zones/db.192.218.3
chmod 644 /etc/bind/zones/db.192.218.3

# Check configuration
echo ""
echo "Checking configuration..."
named-checkconf

if [ $? -ne 0 ]; then
    echo "❌ Configuration error!"
    exit 1
fi
echo "✓ Configuration OK"

# Check reverse zone
named-checkzone 3.218.192.in-addr.arpa /etc/bind/zones/db.192.218.3

if [ $? -ne 0 ]; then
    echo "❌ Reverse zone error!"
    exit 1
fi
echo "✓ Reverse zone OK"

# Reload bind9
echo ""
echo "Reloading bind9..."
rndc reload

sleep 2

echo ""
echo "=========================================="
echo "Setup reverse zone di VALMAR (slave)..."
echo "=========================================="
echo ""
echo "Jalankan di VALMAR:"
echo ""
cat << 'VALMARSCRIPT'
cat > /etc/bind/named.conf.local << 'EOF'
zone "K14.com" {
    type slave;
    file "/var/cache/bind/db.K14.com";
    masters { 192.218.3.2; };
};

zone "3.218.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.192.218.3";
    masters { 192.218.3.2; };
};
EOF

named-checkconf
rndc reload
sleep 3
ls -la /var/cache/bind/
VALMARSCRIPT

echo ""
echo "=========================================="
echo "Setelah Valmar diupdate, test reverse DNS:"
echo "=========================================="
echo ""

echo "Testing reverse DNS queries..."
echo ""
echo "Reverse lookup 192.218.3.4 (Sirion):"
dig @192.218.3.2 -x 192.218.3.4 +short
echo ""
echo "Reverse lookup 192.218.3.5 (Lindon):"
dig @192.218.3.2 -x 192.218.3.5 +short
echo ""
echo "Reverse lookup 192.218.3.6 (Vingilot):"
dig @192.218.3.2 -x 192.218.3.6 +short
echo ""

echo "Full reverse query untuk 192.218.3.4:"
dig @192.218.3.2 -x 192.218.3.4

echo ""
echo "✅ SOAL 8 SELESAI setelah Valmar diupdate!"
