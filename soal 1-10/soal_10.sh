#!/bin/bash

# SOAL 10: Setup Web Dinamis (PHP-FPM) di Vingilot
# Jalankan di: VINGILOT

echo "=========================================="
echo "SOAL 10: Setup Web Dinamis di Vingilot"
echo "=========================================="
echo ""

# Install nginx dan PHP-FPM
echo "Installing nginx and PHP-FPM..."
apt-get update
apt-get install -y nginx php8.4-fpm php8.4-cli

if [ $? -ne 0 ]; then
    echo "⚠️  php8.4 not found, trying php8.2..."
    apt-get install -y nginx php8.2-fpm php8.2-cli
    PHP_VERSION="8.2"
else
    PHP_VERSION="8.4"
fi

echo "✓ nginx and PHP $PHP_VERSION installed"

# Stop services
service nginx stop 2>/dev/null
service php${PHP_VERSION}-fpm stop 2>/dev/null

# Buat direktori web
echo ""
echo "Creating web directories..."
mkdir -p /var/www/app

# Buat halaman index.php
cat > /var/www/app/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Vingilot - Dynamic Web</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; }
        .info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .php-info { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>⛵ Welcome to Vingilot</h1>
        <p>Dynamic Web Application (PHP-FPM)</p>
        
        <div class="info">
            <h3>Server Information:</h3>
            <p class="php-info">PHP Version: <?php echo phpversion(); ?></p>
            <p><strong>Server:</strong> <?php echo $_SERVER['SERVER_NAME']; ?></p>
            <p><strong>Server IP:</strong> <?php echo $_SERVER['SERVER_ADDR']; ?></p>
            <p><strong>Client IP:</strong> <?php echo $_SERVER['REMOTE_ADDR']; ?></p>
            <p><strong>Current Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
        </div>
        
        <hr>
        <p><a href="/about">About Page →</a></p>
    </div>
</body>
</html>
EOF

# Buat halaman about.php
cat > /var/www/app/about.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>About - Vingilot</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 { color: #f5576c; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📖 About Vingilot</h1>
        <p>This is the about page of the Vingilot dynamic web application.</p>
        <p><strong>Vingilot</strong> is the ship of Eärendil, the Mariner.</p>
        <p>It was built by the hands of Círdan the Shipwright in the havens of Sirion.</p>
        <p>Upon this ship, Eärendil sailed to Valinor to seek aid from the Valar.</p>
        <hr>
        <p>Note: This page is accessed via <code>/about</code> (without .php extension)</p>
        <p><a href="/">← Back to Home</a></p>
    </div>
</body>
</html>
EOF

echo "✓ PHP files created"

# Detect PHP-FPM socket
echo ""
echo "Detecting PHP-FPM socket..."
SOCKET=$(ls /var/run/php/php*-fpm.sock 2>/dev/null | head -1)

if [ -z "$SOCKET" ]; then
    # Try starting PHP-FPM first
    service php${PHP_VERSION}-fpm start
    sleep 2
    SOCKET=$(ls /var/run/php/php*-fpm.sock 2>/dev/null | head -1)
fi

if [ -z "$SOCKET" ]; then
    echo "❌ Cannot find PHP-FPM socket!"
    echo "Available sockets:"
    ls -la /var/run/php/ 2>/dev/null
    exit 1
fi

echo "✓ Found socket: $SOCKET"

# Konfigurasi nginx dengan socket yang terdeteksi
echo ""
echo "Configuring nginx..."

cat > /etc/nginx/sites-available/app << EOF
server {
    listen 80;
    server_name app.K14.com;

    root /var/www/app;
    index index.php index.html;

    # PHP-FPM configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$SOCKET;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    # Rewrite untuk /about tanpa .php
    location /about {
        try_files \$uri /about.php;
    }

    # Default location
    location / {
        try_files \$uri \$uri/ =404;
    }

    access_log /var/log/nginx/app-access.log;
    error_log /var/log/nginx/app-error.log;
}
EOF

echo "✓ Using socket: $SOCKET"

# Enable site
ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/
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

# Start PHP-FPM
echo ""
echo "Starting PHP-FPM..."
service php${PHP_VERSION}-fpm restart

sleep 2

# Start nginx
echo ""
echo "Starting nginx..."
service nginx restart

sleep 2

# Verify services
echo ""
echo "Verifying services..."

if ss -tulpn | grep :80 >/dev/null; then
    echo "✓ nginx is listening on port 80"
else
    echo "⚠️ nginx might not be running"
fi

if [ -S "$SOCKET" ]; then
    echo "✓ PHP-FPM socket exists"
else
    echo "⚠️ PHP-FPM socket not found"
fi

echo ""
echo "=========================================="
echo "✅ SOAL 10 SELESAI!"
echo "=========================================="
echo ""

echo "Testing from localhost..."
echo ""
echo "Test 1: Homepage"
curl -s http://localhost | grep -i "vingilot\|PHP Version" | head -5
echo ""
echo "Test 2: /about page"
curl -s http://localhost/about | grep -i "about\|earendil" | head -3
echo ""

echo "=========================================="
echo "Verifikasi dari klien:"
echo "=========================================="
echo "Jalankan di klien (Earendil/Cirdan):"
echo ""
echo "  curl http://app.K14.com"
echo "  curl http://app.K14.com/about"
echo "  curl http://app.K14.com | grep 'PHP Version'"
echo ""
echo "⚠️  Pastikan akses pakai HOSTNAME, bukan IP!"
echo ""
echo "Jika ada error 502, jalankan fix script:"
echo "  ./fix_php.sh"
