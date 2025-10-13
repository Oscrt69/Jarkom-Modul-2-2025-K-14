#!/bin/bash

# SOAL 9: Setup Web Statis di Lindon dengan autoindex
# Jalankan di: LINDON

echo "=========================================="
echo "SOAL 9: Setup Web Statis di Lindon"
echo "=========================================="
echo ""

# Install nginx
echo "Installing nginx..."
apt-get update
apt-get install -y nginx

if [ $? -ne 0 ]; then
    echo "❌ Failed to install nginx"
    exit 1
fi
echo "✓ nginx installed"

# Stop nginx sementara
service nginx stop

# Buat direktori web dan annals
echo ""
echo "Creating web directories..."
mkdir -p /var/www/static
mkdir -p /var/www/static/annals

# Buat halaman utama
cat > /var/www/static/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Lindon - Static Web</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f0f0f0;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #2c3e50; }
        .info { color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏛️ Welcome to Lindon</h1>
        <p class="info">Static Web Server</p>
        <p>This is the static web server running on Lindon (static.K14.com)</p>
        <hr>
        <p><a href="/annals/">Browse Annals Directory →</a></p>
    </div>
</body>
</html>
EOF

# Buat beberapa file di folder annals untuk testing
cat > /var/www/static/annals/file1.txt << 'EOF'
This is file 1 in annals directory.
War of Wrath archives.
EOF

cat > /var/www/static/annals/file2.txt << 'EOF'
This is file 2 in annals directory.
Historical records of Beleriand.
EOF

cat > /var/www/static/annals/file3.txt << 'EOF'
This is file 3 in annals directory.
Chronicles of the First Age.
EOF

echo "✓ Web content created"

# Konfigurasi nginx
echo ""
echo "Configuring nginx..."

cat > /etc/nginx/sites-available/static << 'EOF'
server {
    listen 80;
    server_name static.K14.com;

    root /var/www/static;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Autoindex untuk /annals/
    location /annals/ {
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }

    access_log /var/log/nginx/static-access.log;
    error_log /var/log/nginx/static-error.log;
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/static /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test nginx config
echo ""
echo "Testing nginx configuration..."
nginx -t

if [ $? -ne 0 ]; then
    echo "❌ nginx configuration error!"
    exit 1
fi
echo "✓ nginx configuration OK"

# Start nginx
echo ""
echo "Starting nginx..."
service nginx start

sleep 2

# Check if nginx is running
if pidof nginx >/dev/null; then
    echo "✓ nginx is running"
else
    echo "❌ nginx failed to start!"
    exit 1
fi

echo ""
echo "=========================================="
echo "✅ SOAL 9 SELESAI!"
echo "=========================================="
echo ""

echo "Testing web server..."
echo ""
echo "Test 1: Homepage"
curl -s http://static.K14.com | head -20
echo ""
echo "Test 2: Autoindex /annals/"
curl -s http://static.K14.com/annals/ | grep -i "file[1-3].txt"
echo ""

echo "=========================================="
echo "Verifikasi dari klien:"
echo "=========================================="
echo "1. Dari klien (Earendil/Cirdan), akses:"
echo "   curl http://static.K14.com"
echo "   curl http://static.K14.com/annals/"
echo ""
echo "2. Atau gunakan browser (jika ada GUI)"
echo "   http://static.K14.com"
echo "   http://static.K14.com/annals/"
echo ""
echo "⚠️  Pastikan akses pakai HOSTNAME, bukan IP!"
