# Backup zone file
cp /etc/bind/zones/k14.com.zone /etc/bind/zones/k14.com.zone.backup

# Update zone file dengan IP baru Lindon dan TTL 30 detik
cat > /etc/bind/zones/k14.com.zone << 'EOF'
$TTL    30
@       IN      SOA     ns1.k14.com. admin.k14.com. (
                              2024102003 ; Serial
                          604800     ; Refresh
                           86400     ; Retry
                        2419200     ; Expire
                            30 )    ; Negative Cache TTL
;
@       IN      NS      ns1.k14.com.
@       IN      NS      ns2.k14.com.

; A records
@       IN      A       10.15.43.37
ns1     IN      A       10.15.43.35
ns2     IN      A       10.15.43.36
sirion  IN      A       10.15.43.37
lindon  IN      A       10.15.43.40  ; IP BARU
vingilot IN     A       10.15.43.39

; CNAME records
www     IN      CNAME   sirion
static  IN      CNAME   lindon
app     IN      CNAME   vingilot
EOF

# Restart BIND9
systemctl restart bind9
