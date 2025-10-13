#!/bin/bash

# Konfigurasi Basic Auth untuk path /admin
echo "Mengkonfigurasi Basic Auth untuk /admin..."

# Install apache2-utils untuk htpasswd
apt update
apt install -y apache2-utils

# Buat direktori untuk password file
mkdir -p /etc/nginx/conf.d

# Buat password file (username: admin, password: admin123)
htpasswd -bc /etc/nginx/conf.d/.htpasswd admin admin123

# Update konfigurasi nginx untuk menambahkan basic auth
cat > /etc/nginx/conf.d/admin-auth.conf << 'EOF'
location /admin {
    auth_basic "Administration Area";
    auth_basic_user_file /etc/nginx/conf.d/.htpasswd;
    return 200 "Admin Area - Access Granted";
    add_header Content-Type text/plain;
}
EOF

# Update konfigurasi utama Sirion
cat > /etc/nginx/sites-available/sirion.conf << 'EOF'
server {
    listen 5151;
    server_name sirion.k-14.com www.k-14.com;
    
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

# Restart nginx dengan menghentikan dan memulai ulang
nginx -s stop 2>/dev/null || true
nginx

echo "Basic Auth untuk /admin berhasil dikonfigurasi!"
echo "Username: admin, Password: admin123"