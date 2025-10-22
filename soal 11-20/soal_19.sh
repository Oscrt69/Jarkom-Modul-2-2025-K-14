#!/bin/bash

# SOAL 19: Tambahkan CNAME havens.K14.com -> www.K14.com
# Jalankan di: TIRION (ns1)

echo "=========================================="
echo "SOAL 19: CNAME havens -> www"
echo "=========================================="
echo ""

# Backup zona file
echo "Creating backup..."
cp /etc/bind/zones/db.K14.com /etc/bind/zones/db.K14.com.backup19
echo "✓ Backup created"

# Update zona file dengan CNAME havens
echo ""
echo "Updating zone file..."

cat > /etc/bind/zones/db.K14.com << 'EOF'
$TTL    604800
@       IN      SOA     ns1.K14.com. admin.K14.com. (
                         2025101205     ; Serial (increment)
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

; Apex record
@                   IN      A       192.218.3.4

; A records untuk semua node
eonwe.K14.com.      IN      A       192.218.1.1
earendil.K14.com.   IN      A       192.218.1.2
elwing.K14.com.     IN      A       192.218.1.3
cirdan.K14.com.     IN      A       192.218.2.2
elrond.K14.com.     IN      A       192.218.2.3
maglor.K14.com.     IN      A       192.218.2.4

; A records untuk DMZ
sirion.K14.com.     IN      A       192.218.3.4
lindon.K14.com. 30  IN      A       192.218.3.7
vingilot.K14.com.   IN      A       192.218.3.6

; CNAME records
www.K14.com.        IN      CNAME   sirion.K14.com.
static.K14.com. 30  IN      CNAME   lindon.K14.com.
app.K14.com.        IN      CNAME   vingilot.K14.com.

; SOAL 18: TXT record untuk Melkor
melkor.K14.com.     IN      TXT     "Morgoth (Melkor)"

; SOAL 18: CNAME Morgoth -> Melkor
morgoth.K14.com.    IN      CNAME   melkor.K14.com.

; SOAL 19: CNAME Havens -> www
havens.K14.com.     IN      CNAME   www.K14.com.
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
    echo "✗ Zone file error! Restoring backup..."
    cp /etc/bind/zones/db.K14.com.backup19 /etc/bind/zones/db.K14.com
    exit 1
fi
echo "✓ Zone file OK"

# Reload bind9
echo ""
echo "Reloading bind9..."
rndc reload

sleep 3

# Check SOA serial
echo ""
echo "Checking SOA serial..."
NS1_SERIAL=$(dig @localhost K14.com SOA +short | awk '{print $3}')
echo "ns1 serial: $NS1_SERIAL"

# Wait for zone transfer to ns2
echo ""
echo "Waiting for zone transfer to ns2..."
sleep 5

NS2_SERIAL=$(dig @192.218.3.3 K14.com SOA +short | awk '{print $3}')
echo "ns2 serial: $NS2_SERIAL"

if [ "$NS1_SERIAL" = "$NS2_SERIAL" ]; then
    echo "✓ Zone transfer successful! Both serials: $NS1_SERIAL"
else
    echo "⚠ Warning: Serials differ. Waiting 5 more seconds..."
    sleep 5
    NS2_SERIAL=$(dig @192.218.3.3 K14.com SOA +short | awk '{print $3}')
    echo "ns2 serial now: $NS2_SERIAL"
fi

echo ""
echo "=========================================="
echo "✅ SOAL 19 SELESAI!"
echo "=========================================="
echo ""

# Test CNAME havens
echo "Testing CNAME havens.K14.com:"
echo ""
echo "From ns1:"
dig @192.218.3.2 havens.K14.com +short
echo ""
echo "From ns2:"
dig @192.218.3.3 havens.K14.com +short
echo ""

# Full query untuk melihat CNAME chain
echo "Full query (showing CNAME chain):"
dig @192.218.3.2 havens.K14.com
echo ""

echo "=========================================="
echo "Verifikasi dari 2 KLIEN BERBEDA:"
echo "=========================================="
echo ""
echo "KLIEN 1 (misal: Earendil):"
echo "  dig havens.K14.com"
echo "  dig havens.K14.com +short"
echo "  curl http://havens.K14.com"
echo ""
echo "KLIEN 2 (misal: Cirdan):"
echo "  dig havens.K14.com"
echo "  dig havens.K14.com +short"
echo "  curl http://havens.K14.com"
echo ""
echo "Expected DNS resolution chain:"
echo "  havens.K14.com → www.K14.com → sirion.K14.com → 192.218.3.4"
echo ""
echo "Expected HTTP behavior:"
echo "  http://havens.K14.com → redirect 301 → http://www.K14.com/"
echo "  (karena soal 13: canonical redirect)"
