# Di Sirion - Script lengkap install + konfigurasi
cat > /root/setup_sirion_complete.sh << 'EOF'
#!/bin/bash

echo "=========================================="
echo "Setup Sirion Complete (Soal 11-13)"
echo "=========================================="

# Install nginx
echo "Installing nginx..."
apt-get update
apt-get install -y nginx apache2-utils

mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled
mkdir -p /var/www/sirion
mkdir -p /etc/nginx/auth

# Buat htpasswd untuk soal 12
echo "Creating Basic Auth..."
htpasswd -bc /etc/nginx/auth/.htpasswd admin warofwrath

# Buat direktori admin
mkdir -p /var/www/sirion/admin

# Homepage Sirion
cat > /var/www/sirion/index.html << 'EOFHTML'
<!DOCTYPE html>
<html>
<head>
    <title>Sirion Gateway</title>
</head>
<body>
    <h1>Welcome to Sirion</h1>
    <p>Reverse Proxy Gateway</p>
    <ul>
        <li><a href="/static/">Static Content (Lindon)</a></li>
        <li><a href="/app/">Dynamic App (Vingilot)</a></li>
        <li><a href="/admin/">Admin Panel (Protected)</a></li>
    </ul>
</body>
</html>
EOFHTML

# Admin page
cat > /var/www/sirion/admin/index.html << 'EOFHTML'
<!DOCTYPE html>
<html>
<head>
    <title>Admin Panel - Sirion</title>
</head>
<body>
    <h1>🔐 Admin Panel</h1>
    <p>You have successfully authenticated!</p>
    <p>Username: admin | Password: warofwrath</p>
</body>
</html>
EOFHTML

# Konfigurasi nginx
cat > /etc/nginx/sites-available/sirion << 'EOFNGINX'
# Redirect dari IP ke www.K14.com
server {
    listen 80 default_server;
    server_name 192.218.3.4;
    return 301 http://www.K14.com$request_uri;
}

# Redirect dari sirion.K14.com ke www.K14.com
server {
    listen 80;
    server_name sirion.K14.com;
    return 301 http://www.K14.com$request_uri;
}

# Main server
server {
    listen 80;
    server_name www.K14.com;

    # /static → Lindon
    location /static/ {
        proxy_pass http://192.218.3.5/;
        proxy_set_header Host static.K14.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location = /static {
        return 301 /static/;
    }

    # /app → Vingilot
    location /app/ {
        proxy_pass http://192.218.3.6/;
        proxy_set_header Host app.K14.com;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location = /app {
        return 301 /app/;
    }

    # /admin dengan Basic Auth
    location /admin {
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/auth/.htpasswd;
        root /var/www/sirion;
        index index.html;
    }

    # Root
    location / {
        root /var/www/sirion;
        index index.html;
    }

    access_log /var/log/nginx/sirion-access.log;
    error_log /var/log/nginx/sirion-error.log;
}
EOFNGINX

# Enable site
ln -sf /etc/nginx/sites-available/sirion /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test config
nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Config OK"
    service nginx restart
    echo "✓ Nginx started"
else
    echo "❌ Config error!"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ Sirion Setup Complete!"
echo "=========================================="
echo ""
echo "Testing..."
curl -I http://localhost/static/
curl -I http://localhost/app/

EOF

chmod +x /root/setup_sirion_complete.sh

