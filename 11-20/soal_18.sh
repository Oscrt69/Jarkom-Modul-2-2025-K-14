# Update zone file
cat > /etc/bind/zones/k14.com.zone << 'EOF'
$TTL    30
@       IN      SOA     ns1.k14.com. admin.k14.com. (
                              2024102004 ; Serial
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
lindon  IN      A       10.15.43.40
vingilot IN     A       10.15.43.39

; CNAME records
www     IN      CNAME   sirion
static  IN      CNAME   lindon
app     IN      CNAME   vingilot
morgoth IN      CNAME   melkor

; TXT record
melkor  IN      TXT     "Morgoth (Melkor)"
EOF

systemctl restart bind9

nslookup -type=TXT melkor.k14.com localhost
nslookup -type=CNAME morgoth.k14.com localhost
