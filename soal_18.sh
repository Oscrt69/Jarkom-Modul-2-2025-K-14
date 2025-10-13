#!/bin/bash

# Tambahkan record TXT Melkor dan CNAME Morgoth
echo "Menambahkan record TXT Melkor dan CNAME Morgoth..."

# Update zone file
cat > /etc/bind/zones/k-14.com.zone << 'EOF'
$TTL 30
$ORIGIN k-14.com.
@       IN      SOA     ns1.k-14.com. admin.k-14.com. (
                        2024101003 ; Serial
                        28800      ; Refresh
                        7200       ; Retry
                        604800     ; Expire
                        30         ; Minimum TTL
                        )

; NS Records
@       IN      NS      ns1.k-14.com.
@       IN      NS      ns2.k-14.com.

; A Records
@       IN      A       10.15.43.32    ; Sirion
ns1     IN      A       10.15.43.32    ; Tirion
ns2     IN      A       10.15.43.32    ; Valmar
sirion  IN      A       10.15.43.32
lindon  IN      A       10.15.43.33
vingilot IN     A       10.15.43.32
www     IN      CNAME   sirion
static  IN      CNAME   lindon
app     IN      CNAME   vingilot
havens  IN      CNAME   www

; Evil records
melkor  IN      TXT     "Morgoth (Melkor)"
morgoth IN      CNAME   melkor

; Client records
earendil IN     A       10.15.43.32
elwing   IN      A       10.15.43.32
cirdan   IN      A       10.15.43.32
elrond   IN      A       10.15.43.32
maglor   IN      A       10.15.43.32
EOF

# Restart BIND9
service bind9 restart

echo "Record TXT dan CNAME berhasil ditambahkan!"

# Verifikasi
echo "Verifikasi record TXT:"
nslookup -type=TXT melkor.k-14.com localhost

echo "Verifikasi CNAME:"
nslookup -type=CNAME morgoth.k-14.com localhost