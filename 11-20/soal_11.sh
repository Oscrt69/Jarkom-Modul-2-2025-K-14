#!/bin/bash
echo "=== SOAL 11: SIRION REVERSE PROXY ==="

# Install nginx
apt update && apt install -y nginx

# Backup config
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Buat config reverse proxy
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name sirion.k14.com www.k14.com;
    
    # Root location
    location / {
        root /var/www/html;
        index index.html index.htm;
    }
    
    # Reverse proxy ke Lindon (static)
    location /static/ {
        proxy_pass http://10.15.43.38/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        rewrite ^/static/(.*)$ /$1 break;
    }
    
    # Reverse proxy ke Vingilot (app)
    location /app/ {
        proxy_pass http://10.15.43.39/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        rewrite ^/app/(.*)$ /$1 break;
    }
}
EOF

# Buat halaman utama Sirion
mkdir -p /var/www/html
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Sirion Gateway</title>
</head>
<body>
    <h1>Sirion Reverse Proxy</h1>
    <p><a href="/static/">Static Content (Lindon)</a></p>
    <p><a href="/app/">Dynamic App (Vingilot)</a></p>
</body>
</html>
EOF

# Test & restart nginx
nginx -t && systemctl restart nginx
echo "✅ Soal 11 selesai: Reverse Proxy path-based routing"
