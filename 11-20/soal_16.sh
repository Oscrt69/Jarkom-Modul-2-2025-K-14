#!/bin/bash

# Script untuk perubahan IP Lindon dan TTL
echo "Mengubah IP Lindon dan mengatur TTL..."

# Update zone file di Tirion (ns1)
cat > /etc/bind/zones/k-14.com.zone << 'EOF'
$TTL 30
$ORIGIN k-14.com.
@       IN      SOA     ns1.k-14.com. admin.k-14.com. (
                        2024101002 ; Serial
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
lindon  IN      A       10.15.43.33    ; IP Baru Lindon
vingilot IN     A       10.15.43.32
www     IN      CNAME   sirion
static  IN      CNAME   lindon
app     IN      CNAME   vingilot
havens  IN      CNAME   www
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

echo "IP Lindon diubah menjadi 10.15.43.33 dengan TTL 30 detik"
echo "Serial number diperbarui: 2024101002"

# Verifikasi perubahan
echo "Verifikasi perubahan:"
nslookup lindon.k-14.com localhost