#!/bin/bash

# Konfigurasi Access Log dengan IP Asli di Vingilot
echo "Mengkonfigurasi Access Log dengan IP Asli di Vingilot..."

# Install nginx dan PHP-FPM di Vingilot
apt update
apt install -y nginx php8.4-fpm

# Buat konfigurasi nginx untuk Vingilot
cat > /etc/nginx/sites-available/vingilot.conf << 'EOF'
server {
    listen 5526;
    server_name vingilot.k-14.com app.k-14.com;
    
    root /var/www/vingilot;
    index index.php index.html;
    
    # Access log dengan format yang mencatat X-Real-IP
    access_log /var/log/nginx/vingilot-access.log custom;
    
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param REMOTE_ADDR $http_x_real_ip;
        fastcgi_param HTTP_X_REAL_IP $http_x_real_ip;
    }
    
    # Rewrite untuk /about tanpa .php
    location /about {
        try_files $uri /about.php;
    }
}

# Custom log format untuk menangkap X-Real-IP
log_format custom '$http_x_real_ip - $remote_user [$time_local] '
                  '"$request" $status $body_bytes_sent '
                  '"$http_referer" "$http_user_agent"';
EOF

# Buat direktori web dan file PHP
mkdir -p /var/www/vingilot

# File index.php
cat > /var/www/vingilot/index.php << 'EOF'
<?php
echo "<h1>Vingilot - Dynamic Web</h1>";
echo "<p>Client IP: " . ($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']) . "</p>";
echo "<p>Server IP: " . $_SERVER['SERVER_ADDR'] . "</p>";
echo '<p><a href="/about">About Page</a></p>';
?>
EOF

# File about.php
cat > /var/www/vingilot/about.php << 'EOF'
<?php
echo "<h1>About Vingilot</h1>";
echo "<p>This is the about page without .php extension</p>";
echo "<p>Client IP: " . ($_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR']) . "</p>";
echo '<p><a href="/">Home</a></p>';
?>
EOF

# Aktifkan konfigurasi
ln -sf /etc/nginx/sites-available/vingilot.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Set permissions
chown -R www-data:www-data /var/www/vingilot

# Start services
nginx -t && nginx
service php8.4-fpm start

echo "Access Log dengan IP asli berhasil dikonfigurasi di Vingilot!"