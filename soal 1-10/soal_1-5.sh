#node EARENDIL
cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname earendil
echo "earendil" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.1.2/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.1.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Earendil configured!"
ping -c 2 google.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

#node elwing
#!/bin/bash
hostname elwing
echo "elwing" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 192.218.1.3/24 dev eth0
ip link set eth0 up
ip route add default via 192.218.1.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Elwing configured!"
ping -c 2 google.com

#node cirdan
cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname cirdan
echo "cirdan" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.2.2/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.2.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Cirdan configured!"
ping -c 2 google.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

#node elrond 
cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname elrond
echo "elrond" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.2.3/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.2.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Elrond configured!"
ping -c 2 google.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

#node  maglor

cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname maglor
echo "maglor" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.2.4/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.2.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Maglor configured!"
ping -c 2 google.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

#node sirion
cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname sirion
echo "sirion" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.3.4/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Sirion configured!"
ping -c 2 google.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

#node lindon
cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname lindon
echo "lindon" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.3.5/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Lindon configured!"
ping -c 2 google.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

#node vingilot 
cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname vingilot
echo "vingilot" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.3.6/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "Vingilot configured!"
ping -c 2 google.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

#node  tirion
cat > /root/setup.sh << 'EOF'
#!/bin/bash
hostname tirion
echo "tirion" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.3.2/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "Installing bind9..."
apt-get update
apt-get install -y bind9 bind9utils dnsutils

cat > /etc/bind/named.conf.options << 'EOFBIND'
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation auto;
    listen-on-v6 { any; };
    allow-query { any; };
};
EOFBIND

cat > /etc/bind/named.conf.local << 'EOFBIND'
zone "K14.com" {
    type master;
    file "/etc/bind/zones/db.K14.com";
    notify yes;
    allow-transfer { 10.15.3.3; };
};
EOFBIND

mkdir -p /etc/bind/zones

cat > /etc/bind/zones/db.K14.com << 'EOFBIND'
$TTL    604800
@       IN      SOA     ns1.K14.com. admin.K14.com. (
                         2025101201
                         604800
                         86400
                         2419200
                         604800 )
@       IN      NS      ns1.K14.com.
@       IN      NS      ns2.K14.com.

ns1.K14.com.        IN      A       10.15.3.2
ns2.K14.com.        IN      A       10.15.3.3
@                   IN      A       10.15.3.4

eonwe.K14.com.      IN      A       10.15.1.1
earendil.K14.com.   IN      A       10.15.1.2
elwing.K14.com.     IN      A       10.15.1.3
cirdan.K14.com.     IN      A       10.15.2.2
elrond.K14.com.     IN      A       10.15.2.3
maglor.K14.com.     IN      A       10.15.2.4
sirion.K14.com.     IN      A       10.15.3.4
lindon.K14.com.     IN      A       10.15.3.5
vingilot.K14.com.   IN      A       10.15.3.6
EOFBIND

chown -R bind:bind /etc/bind/zones
chmod -R 755 /etc/bind/zones

named-checkconf
named-checkzone K14.com /etc/bind/zones/db.K14.com

service bind9 restart

cat > /etc/resolv.conf << 'EOFBIND'
nameserver 10.15.3.2
nameserver 10.15.3.3
nameserver 192.168.122.1
EOFBIND

echo "Tirion (ns1) configured!"
sleep 2
dig @10.15.3.2 K14.com
dig @10.15.3.2 ns1.K14.com
EOF
chmod +x /root/setup.sh && ./root/setup.sh

# node valmar
#!/bin/bash
 cat > /root/setup.sh << 'EOF'
hostname valmar
echo "valmar" > /etc/hostname
ip addr flush dev eth0 2>/dev/null
ip addr add 10.15.3.3/24 dev eth0
ip link set eth0 up
ip route add default via 10.15.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "Installing bind9..."
apt-get update
apt-get install -y bind9 bind9utils dnsutils

cat > /etc/bind/named.conf.options << 'EOFBIND'
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    dnssec-validation auto;
    listen-on-v6 { any; };
    allow-query { any; };
};
EOFBIND

cat > /etc/bind/named.conf.local << 'EOFBIND'
zone "K14.com" {
    type slave;
    file "/var/cache/bind/db.K14.com";
    masters { 10.15.3.2; };
};
EOFBIND

named-checkconf
service bind9 restart

cat > /etc/resolv.conf << 'EOFBIND'
nameserver 10.15.3.2
nameserver 10.15.3.3
nameserver 192.168.122.1
EOFBIND

echo "Valmar (ns2) configured!"
sleep 3
dig @10.15.3.3 K14.com
echo "Checking zone transfer..."
ls -la /var/cache/bind/
EOF
chmod +x /root/setup.sh && ./root/setup.sh
 

#Setelah Tirion & Valmar selesai, jalankan di semua node (kecuali Eonwe)

cat > /etc/resolv.conf << 'EOF'
nameserver 10.15.3.2
nameserver 10.15.3.3
nameserver 192.168.122.1
EOF

echo "Resolver updated!"
nslookup K14.com


#verifikasi dari node manapun

# Test konektivitas lintas subnet (Soal 1-3)
ping -c 2 10.15.1.1    # Gateway Barat
ping -c 2 10.15.2.2    # Cirdan (Timur)
ping -c 2 10.15.3.2    # Tirion (DMZ)
ping -c 2 8.8.8.8      # Internet

# Test DNS (Soal 4-5)
nslookup K14.com
nslookup earendil.K14.com
nslookup cirdan.K14.com
nslookup ns1.K14.com
nslookup ns2.K14.com

dig K14.com
host lindon.K14.com
