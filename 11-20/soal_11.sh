#!/bin/bash

echo "Mengkonfigurasi Reverse Proxy Sirion..."

apt update
apt install -y nginx

cat > /etc/nginx/sites-available/sirion.conf << 'EOF'
server {
    listen 5151;
    server_name sirion.k-14.com www.k-14.com;
    
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
    
    location / {
        return 301 http://www.k-14.com$request_uri;
    }
}

server {
    listen 5151;
    server_name _;
    return 301 http://www.k-14.com$request_uri;
}
EOF

# Aktifkan konfigurasi
ln -sf /etc/nginx/sites-available/sirion.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start nginx manually (Docker environment)
nginx -t && nginx

echo "Reverse Proxy Sirion berhasil dikonfigurasi!"
