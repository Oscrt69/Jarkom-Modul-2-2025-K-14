#!/bin/bash

# SOAL 18: Tambahkan TXT record untuk Melkor dan CNAME Morgoth
# Jalankan di: TIRION (ns1)

echo "=========================================="
echo "SOAL 18: TXT Record Melkor/Morgoth"
echo "=========================================="
echo ""

# Backup zona file
echo "Creating backup..."
cp /etc/bind/zones/db.K14.com /etc/bind/zones/db.K14.com.backup18
echo "✓ Backup created"

# Update zona file dengan TXT record dan CNAME
echo ""
echo "Updating zone file..."

cat > /etc/bind/zones/db.K14.com << 'EOF'
$TTL    604800
@       IN      SOA     ns1.K14.com. admin.K14.com. (
                         2025101204     ; Serial (increment)
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
    cp /etc/bind/zones/db.K14.com.backup18 /etc/bind/zones/db.K14.com
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
echo "✅ SOAL 18 SELESAI!"
echo "=========================================="
echo ""

# Test TXT record
echo "Testing TXT record for melkor.K14.com:"
echo "From ns1:"
dig @192.218.3.2 melkor.K14.com TXT +short
echo ""
echo "From ns2:"
dig @192.218.3.3 melkor.K14.com TXT +short
echo ""

# Test CNAME morgoth -> melkor
echo "Testing CNAME morgoth.K14.com:"
echo "From ns1:"
dig @192.218.3.2 morgoth.K14.com +short
echo ""
echo "From ns2:"
dig @192.218.3.3 morgoth.K14.com +short
echo ""

# Test TXT query via CNAME
echo "Testing TXT query for morgoth.K14.com (via CNAME):"
echo "From ns1:"
dig @192.218.3.2 morgoth.K14.com TXT +short
echo ""
echo "From ns2:"
dig @192.218.3.3 morgoth.K14.com TXT +short
echo ""

echo "=========================================="
echo "Verifikasi dari klien (Earendil/Cirdan):"
echo "=========================================="
echo ""
echo "Test commands:"
echo "  # Query TXT record melkor"
echo "  dig melkor.K14.com TXT"
echo "  dig melkor.K14.com TXT +short"
echo ""
echo "  # Query morgoth (should follow CNAME to melkor)"
echo "  dig morgoth.K14.com"
echo "  dig morgoth.K14.com +short"
echo ""
echo "  # Query TXT via morgoth CNAME"
echo "  dig morgoth.K14.com TXT"
echo "  dig morgoth.K14.com TXT +short"
echo ""

echo "Expected results:"
echo '  melkor.K14.com TXT: "Morgoth (Melkor)"'
echo "  morgoth.K14.com: melkor.K14.com. (CNAME)"
echo '  morgoth.K14.com TXT: "Morgoth (Melkor)" (via CNAME)'
