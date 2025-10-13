#!/bin/bash

# SOAL 7: Tambah A record & CNAME untuk Sirion, Lindon, Vingilot
# Jalankan di: TIRION (ns1)

echo "=========================================="
echo "SOAL 7: Update DNS Records"
echo "=========================================="
echo ""

# Backup zona file lama
cp /etc/bind/zones/db.K14.com /etc/bind/zones/db.K14.com.backup
echo "✓ Backup created"

# Update zona file dengan CNAME records
cat > /etc/bind/zones/db.K14.com << 'EOF'
$TTL    604800
@       IN      SOA     ns1.K14.com. admin.K14.com. (
                         2025101202     ; Serial (ditambah 1)
                         604800         ; Refresh
                         86400          ; Retry
                         2419200        ; Expire
                         604800 )       ; Negative Cache TTL
;
; Name servers
@       IN      NS      ns1.K14.com.
@       IN      NS      ns2.K14.com.

; A records for name servers
ns1.K14.com.        IN      A       192.218.3.2
ns2.K14.com.        IN      A       192.218.3.3

; Apex record (front door -> Sirion)
@                   IN      A       192.218.3.4

; A records untuk semua node
eonwe.K14.com.      IN      A       192.218.1.1
earendil.K14.com.   IN      A       192.218.1.2
elwing.K14.com.     IN      A       192.218.1.3
cirdan.K14.com.     IN      A       192.218.2.2
elrond.K14.com.     IN      A       192.218.2.3
maglor.K14.com.     IN      A       192.218.2.4

; A records untuk DMZ (Soal 7)
sirion.K14.com.     IN      A       192.218.3.4
lindon.K14.com.     IN      A       192.218.3.5
vingilot.K14.com.   IN      A       192.218.3.6

; CNAME records (Soal 7)
www.K14.com.        IN      CNAME   sirion.K14.com.
static.K14.com.     IN      CNAME   lindon.K14.com.
app.K14.com.        IN      CNAME   vingilot.K14.com.
EOF

echo "✓ Zone file updated"

# Set permissions
chown bind:bind /etc/bind/zones/db.K14.com
chmod 644 /etc/bind/zones/db.K14.com

# Check zone file
echo ""
echo "Checking zone file..."
named-checkzone K14.com /etc/bind/zones/db.K14.com

if [ $? -ne 0 ]; then
    echo "❌ Zone file error! Restoring backup..."
    cp /etc/bind/zones/db.K14.com.backup /etc/bind/zones/db.K14.com
    exit 1
fi

echo "✓ Zone file OK"

# Reload bind9
echo ""
echo "Reloading bind9..."
rndc reload

sleep 2

echo ""
echo "=========================================="
echo "✅ SOAL 7 SELESAI!"
echo "=========================================="
echo ""

echo "Testing DNS records..."
echo ""
echo "A records:"
echo "  sirion.K14.com:"
dig @192.218.3.2 sirion.K14.com +short
echo "  lindon.K14.com:"
dig @192.218.3.2 lindon.K14.com +short
echo "  vingilot.K14.com:"
dig @192.218.3.2 vingilot.K14.com +short
echo ""

echo "CNAME records:"
echo "  www.K14.com:"
dig @192.218.3.2 www.K14.com +short
echo "  static.K14.com:"
dig @192.218.3.2 static.K14.com +short
echo "  app.K14.com:"
dig @192.218.3.2 app.K14.com +short
echo ""

echo "Verifikasi dari 2 klien berbeda:"
echo "Jalankan di 2 klien (misal Earendil & Cirdan):"
echo "  nslookup www.K14.com"
echo "  nslookup static.K14.com"
echo "  nslookup app.K14.com"
