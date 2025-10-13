#!/bin/bash

# Konfigurasi Autostart Services untuk Docker
echo "Mengkonfigurasi autostart services untuk Docker environment..."

# Buat script startup untuk Docker
cat > /root/startup-services.sh << 'EOF'
#!/bin/bash

# Start BIND9
service bind9 start

# Start nginx
nginx

# Start PHP-FPM
service php8.4-fpm start

# Keep container running
tail -f /dev/null
EOF

chmod +x /root/startup-services.sh

# Buat supervisor config untuk manage multiple services
apt update
apt install -y supervisor

cat > /etc/supervisor/conf.d/services.conf << 'EOF'
[program:bind9]
command=service bind9 start
autostart=true
autorestart=true

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true

[program:php-fpm]
command=service php8.4-fpm start
autostart=true
autorestart=true
EOF

# Start supervisor
service supervisor start

echo "Autostart services berhasil dikonfigurasi untuk Docker!"
echo "Services akan dijalankan oleh supervisor"