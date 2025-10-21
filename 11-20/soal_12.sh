#!/bin/bash

# Soal 12: Basic Auth untuk path /admin di Sirion

echo "Mengkonfigurasi Basic Auth untuk path /admin..."

# Install apache2-utils untuk membuat password file
apt update
apt install -y apache2-utils

# Buat directory untuk admin
mkdir -p /var/www/admin

# Buat halaman admin
cat > /var/www/admin/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Admin Panel - k14.com</title>
</head>
<body>
    <h1>Admin Panel</h1>
    <p>Welcome to the protected admin area!</p>
    <p>This area is protected by Basic Authentication.</p>
</body>
</html>
EOF

# Buat password file dengan user 'admin' dan password 'admin123'
htpasswd -bc /etc/nginx/.htpasswd admin admin123

# Update konfigurasi nginx untuk menambahkan Basic Auth di path /admin
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name sirion.k14.com www.k14.com;

    # Konfigurasi untuk path /admin dengan Basic Auth
    location /admin {
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        root /var/www;
        index index.html index.htm;
    }

    # Konfigurasi untuk path /static -> Lindon (10.15.43.38)
    location /static/ {
        proxy_pass http://10.15.43.38/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        rewrite ^/static/(.*)$ /$1 break;
    }

    # Konfigurasi untuk path /app -> Vingilot (10.15.43.39)
    location /app/ {
        proxy_pass http://10.15.43.39/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        rewrite ^/app/(.*)$ /$1 break;
    }

    # Root location default
    location / {
        root /var/www/html;
        index index.html index.htm;
    }

    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
EOF

# Set permissions yang tepat untuk password file
chmod 644 /etc/nginx/.htpasswd
chown www-data:www-data /etc/nginx/.htpasswd

# Test konfigurasi nginx
nginx -t

# Restart nginx
systemctl restart nginx

echo "Basic Auth untuk /admin berhasil dikonfigurasi!"
echo "Username: admin"
echo "Password: admin123"
echo "Test dengan: curl -u admin:admin123 http://www.k14.com/admin/"
