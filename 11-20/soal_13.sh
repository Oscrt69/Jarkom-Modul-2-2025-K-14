#!/bin/bash

# Konfigurasi Redirect Kanonik
echo "Mengkonfigurasi Redirect Kanonik..."

# Update konfigurasi nginx untuk redirect kanonik
cat > /etc/nginx/sites-available/sirion.conf << 'EOF'
# Redirect semua akses via IP atau sirion.k-14.com ke www.k-14.com
server {
    listen 5151;
    server_name sirion.k-14.com 10.15.43.32;
    return 301 http://www.k-14.com$request_uri;
}

# Konfigurasi utama untuk www.k-14.com
server {
    listen 5151;
    server_name www.k-14.com;
    
    # Include basic auth configuration
    include /etc/nginx/conf.d/admin-auth.conf;
    
    # Path-based routing
    location /static/ {
        proxy_pass http://10.15.43.32:5209/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /app/ {
        proxy_pass http://10.15.43.32:5526/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Halaman beranda
    location / {
        root /var/www/html;
        index index.html;
    }
}
EOF

# Buat halaman beranda
mkdir -p /var/www/html
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>War of Wrath - Sirion Gateway</title>
</head>
<body>
    <h1>Welcome to Sirion Gateway</h1>
    <p>Redirecting to canonical hostname: www.k-14.com</p>
</body>
</html>
EOF

# Restart nginx
nginx -s stop 2>/dev/null || true
nginx

echo "Redirect kanonik berhasil dikonfigurasi!"